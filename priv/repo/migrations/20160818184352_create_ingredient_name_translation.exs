defmodule Bonbon.Repo.Migrations.CreateIngredientNameTranslation do
    use Ecto.Migration

    def change do
        create table(:ingredient_name_translations, primary_key: false) do
            add :translate_id, :serial,
                primary_key: true#,
                # comment: "The translation group for this entry"

            add :locale_id, references(:locales),
                primary_key: true#,
                # comment: "The language locale for this entry"

            add :term, :string,
                null: false#,
                # comment: "The localised term for the ingredient's name"

            timestamps()
        end
    end
end
