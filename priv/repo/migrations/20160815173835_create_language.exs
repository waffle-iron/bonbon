defmodule Bonbon.Repo.Migrations.CreateLanguage do
    use Ecto.Migration

    def change do
        create table(:languages) do
            add :country, :char,
                size: 2#,
                # comment: "The ISO 3166-1 alpha-2 code for the country"

            add :language, :char,
                size: 2,
                null: false#,
                # comment: "The ISO 639-1 code for the language"

            timestamps()
        end

        create index(:languages, [:country, :language], unique: true)
    end
end
