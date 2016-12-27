defmodule Bonbon.Model.Item.Food.AllergenList do
    use Bonbon.Web, :model
    @moduledoc """
      A model representing the different allergens that apply to the food.
    """

    schema "food_allergen_list" do
        belongs_to :food, Bonbon.Model.Item.Food
        belongs_to :allergen, Bonbon.Model.Allergen
        timestamps
    end

    @doc """
      Builds a changeset based on the `struct` and `params`.
    """
    def changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [:food_id, :allergen_id])
        |> validate_required([:food_id, :allergen_id])
        |> assoc_constraint(:food)
        |> assoc_constraint(:allergen)
        |> unique_constraint(:food_id_allergen_id)
    end
end
