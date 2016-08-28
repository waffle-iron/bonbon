defmodule Bonbon.Repo.Migrations.CreateItem.Food.Content.Translation do
    use Ecto.Migration
    import Translecto.Migration

    def change do
        create table(:food_content_translations, primary_key: false) do
            translation

            add :name, :string,
                null: false#,
                # comment: "The localised name of the food"

            add :description, :string,
                null: false#,
                # comment: "The localised description of the food"

            timestamps
        end
    end
end
