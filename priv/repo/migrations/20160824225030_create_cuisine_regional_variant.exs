defmodule Bonbon.Repo.Migrations.CreateCuisineRegionalVariant do
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

        create table(:cuisine_regional_variant_subregion_translations, primary_key: false) do
            translation

            add :term, :string,
                null: false#,
                # comment: "The localised term for the subregion's name"

            timestamps
        end

        create table(:cuisine_regional_variant_country_translations, primary_key: false) do
            translation

            add :term, :string,
                null: false#,
                # comment: "The localised term for the country's name"

            timestamps
        end

        create table(:cuisine_regional_variant_province_translations, primary_key: false) do
            translation

            add :term, :string,
                null: false#,
                # comment: "The localised term for the province's name"

            timestamps
        end

        create table(:cuisine_regional_variants) do
            translate :continent, null: false
            translate :subregion, null: true
            translate :country, null: true
            translate :province, null: true
            timestamps
        end

        # create index(:cuisine_regional_variants, [:continent, :subregion, :country, :province], unique: true, name: :cuisine_regional_variants_region_index)
        execute("CREATE UNIQUE INDEX cuisine_regional_variants_region_index ON cuisine_regional_variants(continent, COALESCE(subregion, 0), COALESCE(country, 0), COALESCE(province, 0))")
    end
end
