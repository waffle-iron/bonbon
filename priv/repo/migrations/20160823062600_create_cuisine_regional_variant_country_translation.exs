defmodule Bonbon.Repo.Migrations.CreateCuisineRegionalVariantCountryTranslation do
    use Ecto.Migration
    import Translecto.Migration

    def change do
        create table(:cuisine_regional_variant_country_translations, primary_key: false) do
            translation

            add :term, :string,
                null: false#,
                # comment: "The localised term for the country's name"

            timestamps
        end
    end
end
