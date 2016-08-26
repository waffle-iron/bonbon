defmodule Bonbon.Repo.Migrations.CreateAllergen do
    use Ecto.Migration
    import Translecto.Migration

    def change do
        create table(:allergen_name_translations, primary_key: false) do
            translation

            add :term, :string,
                null: false#,
                # comment: "The localised term for the name of the allergen"

            timestamps
        end

        create table(:allergens) do
            translate :name, null: false
            timestamps
        end

        create index(:allergens, [:name], unique: true)
    end
end
