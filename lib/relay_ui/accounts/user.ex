defmodule RelayUi.Accounts.User do
  use Ecto.Schema

  import Ecto.Changeset

  alias RelayUi.Accounts.LoginRequest
  alias RelayUi.Accounts.Session

  schema "users" do
    field :email, :string
    field :name, :string

    timestamps()

    has_one :login_request, LoginRequest
    has_many :sessions, Session
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :name])
    |> validate_required([:email, :name])
    |> unique_constraint(:email)
  end
end
