defmodule RelayUi.Accounts.Users do
  alias RelayUi.Accounts.User
  alias RelayUi.Repo

  def get_by_email(email) do
    Repo.get_by(User, email: email)
  end
end
