defmodule Bonbon.Model.Cuisine.Region do
    use Bonbon.Web, :model
    use Translecto.Schema.Translatable
    import Translecto.Changeset
    @moduledoc """
      A model representing the different cuisine regions.
    """

    schema "cuisine_regions" do
        translatable :continent, Bonbon.Model.Cuisine.Region.Continent.Translation
        translatable :subregion, Bonbon.Model.Cuisine.Region.Subregion.Translation
        translatable :country, Bonbon.Model.Cuisine.Region.Country.Translation
        translatable :province, Bonbon.Model.Cuisine.Region.Province.Translation
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