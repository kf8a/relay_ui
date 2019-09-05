defmodule RelayUi.Accounts.LoginRequest do
  use Ecto.Schema

  alias RelayUi.Accounts.User

  schema "login_requests" do
    timestamps()

    belongs_to :user, User
  end
end
