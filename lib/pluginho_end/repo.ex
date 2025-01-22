defmodule PluginhoEnd.Repo do
  use Ecto.Repo,
    otp_app: :pluginho_end,
    adapter: Ecto.Adapters.Postgres
end
