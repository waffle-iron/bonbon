defmodule Bonbon.Model.Item.Food.DietList do
    use Bonbon.Web, :model
    @moduledoc """
      A model representing the different diets that apply to the food.
    """

    schema "food_diet_list" do
        belongs_to :food, Bonbon.Model.Item.Food
        belongs_to :diet, Bonbon.Model.Diet
        timestamps
    end

    @doc """
      Builds a changeset based on the `struct` and `params`.
    """
    def changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [:food_id, :diet_id])
        |> validate_required([:food_id, :diet_id])
        |> assoc_constraint(:food)
        |> assoc_constraint(:diet)
        |> unique_constraint(:food_id_diet_id)
    end
end
