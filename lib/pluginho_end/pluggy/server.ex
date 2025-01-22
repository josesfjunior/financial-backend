defmodule PluginhoEnd.Pluggy.Server do
  use GenServer
  require Logger

  @url "https://api.pluggy.ai/auth"
  @connect_token_url "https://api.pluggy.ai/connect_token"

  def start_link(params \\ %{}) do
    GenServer.start_link(__MODULE__, params, name: __MODULE__)
  end

  @impl true
  def init(params) do
    {:ok, params, {:continue, :init_state}}
  end

  def get_credentials, do: GenServer.call(__MODULE__, :get_credentials)

  @impl GenServer
  def handle_continue(:init_state, %{} = state) do
    day = 1000 * 60 * 60 * 24

    client_id =
      Application.get_all_env(:pluginho_end)
      |> Keyword.get(PluginhoEnd.Pluggy.Server)
      |> Keyword.get(:client_id)

    client_secret =
      Application.get_all_env(:pluginho_end)
      |> Keyword.get(PluginhoEnd.Pluggy.Server)
      |> Keyword.get(:client_secret)

    Process.send_after(self(), :renew_token, day)
    Process.send(self(), :init_token, [])

    {
      :noreply,
      state
      |> Map.put(:api_token, "")
      |> Map.put(:client_id, client_id)
      |> Map.put(:client_secret, client_secret)
    }
  end

  @impl true
  def handle_call(:get_credentials, _from, %{api_token: api_token} = state) do
    case get_credentias(api_token) do
      %{data: %{"accessToken" => token}} ->
        {:reply, {:ok, token}, state}

      reason ->
        {:reply, reason, state}
    end
  end

  @impl true
  def handle_info(:renew_token, state) do
    Process.send(self(), :init_token, [])
    {:noreply, state}
  end

  def handle_info(:init_token, %{client_id: c_id, client_secret: c_st} = state) do
    case get_token(c_id, c_st) do
      {:ok, %{"apiKey" => token}} ->
        {:noreply, Map.put(state, :api_token, token)}

      {:error, reason} ->
        IO.inspect(reason)
        {:noreply, state}
    end
  end

  defp get_token(client_id, client_secret) do
    headers = [
      {"accept", "application/json"},
      {"content-type", "application/json"}
    ]

    body =
      %{
        clientId: client_id,
        clientSecret: client_secret
      }
      |> Jason.encode!()

    case HTTPoison.post(@url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: status, body: response_body}}
      when status in 200..299 ->
        {:ok, Jason.decode!(response_body)}

      {:ok, %HTTPoison.Response{status_code: status, body: response_body}} ->
        {:error, %{status: status, body: response_body}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp get_credentias(api_key) do
    headers = [
      {"X-API-KEY", api_key},
      {"accept", "application/json"},
      {"content-type", "application/json"}
    ]

    case HTTPoison.post(@connect_token_url, "", headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        %{data: Jason.decode!(body)}

      {:ok, %HTTPoison.Response{status_code: _status, body: body}} ->
        %{error: Jason.decode!(body)}
    end
  end
end
