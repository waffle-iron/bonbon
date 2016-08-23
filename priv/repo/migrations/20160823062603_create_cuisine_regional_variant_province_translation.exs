defmodule Bonbon.Repo.Migrations.CreateCuisineRegionalVariantProvinceTranslation do
    use Ecto.Migration
    import Translecto.Migration

    def change do
        create table(:cuisine_regional_variant_province_translations, primary_key: false) do
            translation

            add :term, :string,
                null: false#,
                # comment: "The localised term for the province's name"

            timestamps
        end
    end
end
