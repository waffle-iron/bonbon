defmodule Bonbon.Repo.Migrations.CreateAccount.Business do
    use Ecto.Migration

    def change do
        create table(:businesses) do
            add :email, :string,
                null: false

            add :password_hash, :string,
                null: false

            add :mobile, :string,
                null: false

            add :name, :string,
                null: false

            timestamps
        end

        create index(:businesses, [:email], unique: true)
    end
end
