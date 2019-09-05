defmodule RelayUi.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do

    create table(:users) do
      add :email, :text, null: false
      add :name, :text, null: false

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
