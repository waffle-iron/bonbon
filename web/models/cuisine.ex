defmodule Bonbon.Model.Cuisine do
    use Bonbon.Web, :model
    use Translecto.Schema.Translatable
    @moduledoc """
      A model representing the different cuisines.

      ##Fields

      ###:id
      Is the unique reference to the cuisine entry. Is an `integer`.

      ###:name
      Is the name of the cuisine. Is a `translatable`.

      ###:region_id
      Is the reference to the region the cuisine belongs to. Is an
      `integer` to `Bonbon.Model.Cuisine.Region`.
    """

    schema "cuisines" do
        translatable :name, Bonbon.Model.Cuisine.Name.Translation
        belongs_to :region, Bonbon.Model.Cuisine.Region
        timestamps
    end

    @doc """
      Builds a changeset based on the `struct` and `params`.

      Enforces:
      * `name` field is translatable
      * `name` field is required
      * `region_id` field is required
      * `region_id` field is associated with an entry in `Bonbon.Model.Cuisine.Region`
      * `name` field is unique
    """
    def changeset(struct, params \\ %{}) do
        struct
        |> translatable_changeset(params, [:name])
        |> cast(params, [:region_id])
        |> validate_required([:name, :region_id])
        |> assoc_constraint(:region)
        |> unique_constraint(:name)
    end
end
