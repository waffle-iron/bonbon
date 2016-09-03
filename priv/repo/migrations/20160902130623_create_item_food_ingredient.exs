defmodule Bonbon.Repo.Migrations.CreateItem.Food.IngredientList do
    use Ecto.Migration

    def change do
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
    end
end
