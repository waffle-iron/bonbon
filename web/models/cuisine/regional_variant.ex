defmodule Bonbon.Cuisine.RegionalVariant do
    use Bonbon.Web, :model
    use Translecto.Schema.Translatable
    import Translecto.Changeset

    schema "cuisine_regional_variants" do
        translatable :continent, Bonbon.Cuisine.RegionalVariant.Continent.Translation
        translatable :subregion, Bonbon.Cuisine.RegionalVariant.Subregion.Translation
        translatable :country, Bonbon.Cuisine.RegionalVariant.Country.Translation
        translatable :province, Bonbon.Cuisine.RegionalVariant.Province.Translation
        timestamps
    end

    @doc """
      Builds a changeset based on the `struct` and `params`.
    """
    def changeset(struct, params \\ %{}) do
        struct
        |> translatable_changeset(params, [:continent, :subregion, :country, :province])
        |> validate_required([:continent])
        |> unique_constraint(:region)
    end
end
