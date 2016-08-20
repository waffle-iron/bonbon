defmodule Bonbon.Repo.Migrations.CreateIngredientTypeTranslation do
    use Ecto.Migration
    import Translecto.Migration

    def change do
        create table(:ingredient_type_translations, primary_key: false) do
            translation

            add :term, :string,
                null: false#,
                # comment: "The localised term for the ingredient's type"

            timestamps
        end
    end
end
