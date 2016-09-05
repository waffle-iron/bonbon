defmodule Bonbon.Model.Cuisine do
    use Bonbon.Web, :model
    use Translecto.Schema.Translatable
    @moduledoc """
      A model representing the different cuisines.
    """

    schema "cuisines" do
        translatable :name, Bonbon.Model.Cuisine.Name.Translation
        belongs_to :region, Bonbon.Model.Cuisine.Region
        timestamps
    end

    @doc """
      Builds a changeset based on the `struct` and `params`.
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