defmodule Bonbon.Repo.Migrations.CreateItem.Food.DietList do
    use Ecto.Migration

    def change do
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
