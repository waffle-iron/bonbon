defmodule Bonbon.Repo.Migrations.CreateIngredient do
    use Ecto.Migration
    import Translecto.Migration

    def change do
        create table(:ingredients) do
            translate :type, null: true
            translate :name, null: false
            timestamps
        end

        create index(:ingredients, [:name], unique: true)
    end
end
