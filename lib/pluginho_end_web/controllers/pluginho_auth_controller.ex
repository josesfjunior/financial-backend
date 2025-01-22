defmodule PluginhoEndWeb.PluginhoAuthController do
  use PluginhoEndWeb, :controller
  alias PluginhoEnd.Pluggy.Server
  alias PluginhoEnd.Accounts

  def get_credentials(conn, _params) do
    case Server.get_credentials() do
      {:ok, token} ->
        json(conn, %{status: "success", token: token})

      {:error, reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{status: "error", error: reason})
    end
  end

  def login(conn, %{"email" => email, "password" => password}) do
    case Accounts.get_user_by_email_and_password(email, password) do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{status: "error", error: "Invalid email or password"})

      user ->
        token =
          user
          |> Accounts.generate_user_session_token()
          |> Base.url_encode64(padding: false)

        json(conn, %{
          status: "success",
          user: %{name: user.name, email: user.email, token: token}
        })
    end
  end

  def register(conn, %{"name" => name, "email" => email, "password" => password}) do
    case PluginhoEnd.Accounts.register_user(%{name: name, email: email, password: password}) do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> json(%{status: "success", user: %{id: user.id, name: user.name, email: user.email}})

      {:error, changeset} ->
        errors =
          Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
            Enum.reduce(opts, msg, fn {key, value}, acc ->
              String.replace(acc, "%{#{key}}", to_string(value))
            end)
          end)

        conn
        |> put_status(:unprocessable_entity)
        |> json(%{status: "error", errors: errors})
    end
  end
end
