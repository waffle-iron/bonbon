defmodule Bonbon.Repo.Migrations.CreateItem.Food do
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

        create table(:foods) do
            #todo: type field?
            translate :content,
                null: false

            add :prep_time, :integer #seconds

            add :available, :boolean,
                null: false

            add :cuisine_id, references(:cuisines)

            add :calories, :integer

            add :price, :decimal,
                null: false

            add :currency, :char, #ISO 4217
                size: 3,
                null: false

            add :image, :string,
                null: false

            timestamps
        end

        create index(:foods, [:content], unique: true)

        create table(:food_ingredient_list) do
            add :food_id, references(:foods),
                null: false

            add :ingredient_id, references(:ingredients),
                null: false

            add :addon, :boolean,
                default: false,
                null: false

            add :price, :decimal,
                null: false

            add :currency, :char, #ISO 4217
                size: 3,
                null: false

            timestamps
        end

        create index(:food_ingredient_list, [:food_id, :ingredient_id], unique: true)

        create table(:food_diet_list) do
            add :food_id, references(:foods),
                null: false

            add :diet_id, references(:diets),
                null: false

            timestamps
        end

        create index(:food_diet_list, [:food_id, :diet_id], unique: true)
    end
end
