defmodule Bonbon.Model.Cuisine.Region do
    use Bonbon.Web, :model
    use Translecto.Schema.Translatable
    import Translecto.Changeset
    @moduledoc """
      A model representing the different cuisine regions.

      ##Fields

      ###:id
      Is the unique reference to the region entry. Is an `integer`.

      ###:continent
      Is the continent of the region. Is a `translatable`.

      ###:subregion
      Is the subregion of the region. Is a `translatable`.

      ###:country
      Is the country of the region. Is a `translatable`.

      ###:province
      Is the province of the region. Is a `translatable`.
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

      Enforces:
      * `continent` field is translatable
      * `subregion` field is translatable
      * `country` field is translatable
      * `province` field is translatable
      * `continent` field is required
      * checks uniqueness of the given region fields
    """
    def changeset(struct, params \\ %{}) do
        struct
        |> translatable_changeset(params, [:continent, :subregion, :country, :province])
        |> validate_required([:continent])
        |> unique_constraint(:region)
    end
end
