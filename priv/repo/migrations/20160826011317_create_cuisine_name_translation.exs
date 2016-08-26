defmodule Bonbon.Repo.Migrations.CreateCuisineNameTranslation do
    use Ecto.Migration
    import Translecto.Migration

    def change do
        create table(:cuisine_name_translations, primary_key: false) do
            translation

            add :term, :string,
                null: false#,
                # comment: "The localised term for the cuisine's name"

            timestamps
        end
    end
end
