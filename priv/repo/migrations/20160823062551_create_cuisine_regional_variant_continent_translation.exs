defmodule Bonbon.Repo.Migrations.CreateCuisineRegionalVariantContinentTranslation do
    use Ecto.Migration
    import Translecto.Migration

    def change do
        create table(:cuisine_regional_variant_continent_translations, primary_key: false) do
            translation

            add :term, :string,
                null: false#,
                # comment: "The localised term for the continent's name"

            timestamps
        end
    end
end
