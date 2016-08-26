defmodule Bonbon.Repo.Migrations.CreateDiet do
    use Ecto.Migration
    import Translecto.Migration

    def change do
        create table(:diet_name_translations, primary_key: false) do
            translation

            add :term, :string,
                null: false#,
                # comment: "The localised term for the name of the diet"

            timestamps
        end

        create table(:diets) do
            translate :name, null: false
            timestamps
        end

        create index(:diets, [:name], unique: true)
    end
end
