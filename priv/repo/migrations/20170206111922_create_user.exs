defmodule Bonbon.Repo.Migrations.CreateUser do
    use Ecto.Migration

    def change do
        create table(:users) do
            add :email, :string,
                null: false

            add :password, :string,
                null: false

            add :mobile, :string,
                null: false

            add :first_name, :string,
                null: false

            add :last_name, :string,
                null: false

            timestamps
        end
    end
end
