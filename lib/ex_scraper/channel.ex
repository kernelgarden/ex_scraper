defmodule ExScraper.Channel do
  require Logger

  alias __MODULE__
  alias ExScraper.Channel.Meta
  alias ExScraper.Result
  alias Mint.HTTP

  @type parse_result :: parse_info() | :error

  @type parse_info :: %{origin: binary(), scheme: binary(), base_url: binary(), uri: binary()}

  defstruct meta: nil,
            keywords: []

  @spec build(binary(), Keyword.t()) :: Result.t(Channel.t())
  def build(link, keywords \\ []) do
    link
    |> parse_link()
    |> validate()
    |> case do
      {:ok, meta} ->
        {:ok, %Channel{meta: meta, keywords: keywords}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec parse_link(binary()) :: parse_result()
  def parse_link(link) do
    # 0: full match
    # 1: dummy(not use)
    # 2: protocol scheme
    # 3: base_url
    # 4: uri
    ~r/(([\w\W]*):\/\/)?([^\/?#]+)+([\w\W]*)\/?/
    |> Regex.run(link)
    |> build_parse_info()
  end

  # @spec build_parse_info([binary()]) :: parse_result()
  @spec build_parse_info([...]) :: parse_result()
  def build_parse_info([full, _, scheme, base_url, uri]) do
    %{origin: full, scheme: scheme, base_url: base_url, uri: uri}
  end

  defp validate(parse_info) do
    IO.puts("[Debug] parse_info => #{inspect(parse_info)}")
    # validate link first
    case connect(parse_info) do
      {:ok, conn} ->
        HTTP.request(conn, "GET", "/", [], "")
        |> IO.inspect(label: "[Debug] => ")
        |> handle_response(parse_info)

      err ->
        {:error, err}
    end
  end

  # https case
  defp connect(%{scheme: "https", base_url: base_url} = _parse_info) do
    opts = [transport_opts: [ciphers: :ssl.cipher_suites(:default, :"tlsv1.2")]]
    HTTP.connect(:https, base_url, 443, opts)
  end

  # other case
  defp connect(%{scheme: _, base_url: base_url} = _parse_info) do
    HTTP.connect(:http, base_url, 80)
  end

  defp handle_response({:ok, conn, _req_ref}, parse_info) do
    receive do
      message ->
        case HTTP.stream(conn, message) do
          {:ok, _conn, responses} ->
            case check_status(responses) do
              true -> {:ok, build_meta(responses, parse_info)}
              false -> {:error, "link is Invalid!"}
            end

          :unknown ->
            :noop
        end
    end
  end

  defp handle_response(_unknown, _parse_info) do
    {:error, "Failed to request"}
  end

  defp check_status([]) do
    false
  end

  defp check_status([{:status, _ref, status_code} | _]) do
    if status_code == 200 do
      true
    else
      false
    end
  end

  defp build_meta([{:headers, _ref, headers}, {:data, _ref2, data}] = _responses, parse_info) do
    Meta.new(parse_info, headers, data)
  end

  # Close HTTP Session and return result
  defp graceful_close(result, conn) do
    # HTTP.close(conn)
    result
  end
end
