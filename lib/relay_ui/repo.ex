defmodule RelayUi.Repo do
  use Ecto.Repo,
    otp_app: :relay_ui,
    adapter: Ecto.Adapters.Postgres
end
