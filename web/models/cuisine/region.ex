defmodule Bonbon.Cuisine.Region do
    use Bonbon.Web, :model
    use Translecto.Schema.Translatable
    import Translecto.Changeset

    schema "cuisine_regions" do
        translatable :continent, Bonbon.Cuisine.Region.Continent.Translation
        translatable :subregion, Bonbon.Cuisine.Region.Subregion.Translation
        translatable :country, Bonbon.Cuisine.Region.Country.Translation
        translatable :province, Bonbon.Cuisine.Region.Province.Translation
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
