defmodule RelayUi.Accounts.Sessions do
  alias RelayUi.Accounts.Session
  alias RelayUi.Repo

  def get(id) do
    Repo.get(Session, id)
  end

  def delete(session) do
    Repo.delete(session)
  end
end
