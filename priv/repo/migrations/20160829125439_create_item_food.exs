defmodule Bonbon.Repo.Migrations.CreateItem.Food do
    use Ecto.Migration
    import Translecto.Migration

    def change do
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
    end
end
