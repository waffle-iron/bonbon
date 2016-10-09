defmodule Bonbon.Model.Item.Food.IngredientList do
    use Bonbon.Web, :model
    @moduledoc """
      A model representing the different ingredients of food available to order.
    """

    schema "food_ingredient_list" do
        belongs_to :food, Bonbon.Model.Item.Food
        belongs_to :ingredient, Bonbon.Model.Ingredient
        #todo: Below is to handle optional ingredients/addons, however this approach
        #      might mess with diet tags. As they're being applied to food not
        #      optional collections of ingredients.
        field :addon, :boolean, default: false
        field :price, :decimal
        field :currency, :string
        timestamps
    end

    @doc """
      Builds a changeset based on the `struct` and `params`.
    """
    def changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [:food_id, :ingredient_id, :addon, :price, :currency])
        |> validate_required([:food_id, :ingredient_id, :addon])
        |> validate_length(:currency, is: 3)
        |> format_uppercase(:currency)
        |> assoc_constraint(:food)
        |> assoc_constraint(:ingredient)
        |> unique_constraint(:food_id_ingredient_id)
    end
end
