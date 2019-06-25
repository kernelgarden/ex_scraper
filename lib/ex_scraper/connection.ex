defmodule ExScraper.Connection do
  use GenServer

  require Logger

  alias __MODULE__
  alias ExScraper.Connection.Helper
  alias ExScraper.Connection.Table

  defstruct conn: nil, requests: %{}, results: []

  def start_link(args) do
    host = Keyword.get(args, :host)
    GenServer.start_link(__MODULE__, args, name: Helper.via_tuple(host))
  end

  def request(host, method, path, headers, body) do
    GenServer.call(Helper.via_tuple(host), {:request, method, path, headers, body})
  end

  @impl true
  def init(_args) do
    {:ok, %Connection{}}
  end

  @impl true
  def handle_call({:request, method, path, headers, body}, from, state) do
    case Mint.HTTP.request(state.conn, method, path, headers, body) do
      {:ok, conn, request_ref} ->
        state = put_in(state.conn, conn)
        state = put_in(state.requests[request_ref], %{from: from, response: %{}})
        {:noreply, state}

      {:error, conn, reason} ->
        state = put_in(state.conn, conn)
        {:reply, {:error, reason}, state}
    end
  end

  @impl true
  def handle_info(message, state) do
    case Mint.HTTP.stream(state.conn, message) do
      :unknown ->
        _ = Logger.error(fn -> "Received unknown message: " <> inspect(message) end)
        {:noreply, state}

      {:ok, conn, responses} ->
        state = put_in(state.conn, conn)
        state = Enum.reduce(responses, state, &process_response/2)
        {:noreply, state}

      {:error, _, _, _} ->
        Logger.error(fn -> "Error ocuured!" end)
    end
  end

  defp process_response({:status, request_ref, status}, state) do
    put_in(state.requests[request_ref].response[:status], status)
  end

  defp process_response({:headers, request_ref, headers}, state) do
    put_in(state.requests[request_ref].response[:headers], headers)
  end

  defp process_response({:data, request_ref, data}, state) do
    update_in(state.requests[request_ref].response[:data], fn old_data ->
      (old_data || "") <> data
    end)
  end

  defp process_response({:done, request_ref}, state) do
    {%{response: response, from: from}, state} = pop_in(state.conn[request_ref])
    GenServer.reply(from, {:ok, response})
    state
  end
end
