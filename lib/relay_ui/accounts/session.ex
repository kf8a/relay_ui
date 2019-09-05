defmodule RelayUi.Accounts.Session do
  use Ecto.Schema

  alias RelayUi.Accounts.User

  schema "sessions" do
    timestamps()

    belongs_to :user, User
  end
end
