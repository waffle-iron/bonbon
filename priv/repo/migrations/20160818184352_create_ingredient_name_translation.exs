defmodule Bonbon.Repo.Migrations.CreateIngredientNameTranslation do
    use Ecto.Migration
    import Translecto.Migration

    def change do
        create table(:ingredient_name_translations, primary_key: false) do
            translation

            add :term, :string,
                null: false#,
                # comment: "The localised term for the ingredient's name"

            timestamps
        end
    end
end
