defmodule Bonbon.Model.Item.Food.IngredientListTest do
    use Bonbon.ModelCase

    alias Bonbon.Model.Item.Food.IngredientList

    @valid_model %IngredientList{
        food_id: 1,
        ingredient_id: 1,
        addon: false,
        price: Decimal.new(1),
        currency: "AUD"
    }

    test "empty" do
        refute_change(%IngredientList{})
    end

    test "only food_id" do
        refute_change(%IngredientList{}, %{ food_id: 1 })
    end

    test "only ingredient_id" do
        refute_change(%IngredientList{}, %{ ingredient_id: 1 })
    end

    test "only addon" do
        refute_change(%IngredientList{}, %{ addon: true })
    end

    test "only price" do
        refute_change(%IngredientList{}, %{ price: Decimal.new(1) })
    end

    test "only currency" do
        refute_change(%IngredientList{}, %{ currency: "AUD" })
    end

    test "without food_id" do
        refute_change(@valid_model, %{ food_id: nil })
    end

    test "without ingredient_id" do
        refute_change(@valid_model, %{ ingredient_id: nil })
    end

    test "without addon" do
        refute_change(@valid_model, %{ addon: nil })
    end

    test "without price" do
        assert_change(@valid_model, %{ price: nil })
    end

    test "without currency" do
        assert_change(@valid_model, %{ currency: nil })
    end

    test "currency length" do
        assert_change(@valid_model, %{ currency: "" }) |> assert_change_value(:currency, nil)
        refute_change(@valid_model, %{ currency: "U" })
        refute_change(@valid_model, %{ currency: "US" })
        assert_change(@valid_model, %{ currency: "USD" }) |> assert_change_value(:currency, "USD")
    end

    test "currency casing" do
        assert_change(@valid_model, %{ currency: "usd" }) |> assert_change_value(:currency, "USD")
        assert_change(@valid_model, %{ currency: "Usd" }) |> assert_change_value(:currency, "USD")
        assert_change(@valid_model, %{ currency: "usD" }) |> assert_change_value(:currency, "USD")
        assert_change(@valid_model, %{ currency: "USD" }) |> assert_change_value(:currency, "USD")
    end

    test "uniqueness" do
        food = Bonbon.Repo.insert!(Bonbon.Model.Item.Food.changeset(%Bonbon.Model.Item.Food{}, %{ content: 1, available: true, price: Decimal.new(1), currency: "AUD", image: "image.jpg" }))
        ingredient = Bonbon.Repo.insert!(Bonbon.Model.Ingredient.changeset(%Bonbon.Model.Ingredient{}, %{ name: 1, type: 1 }))
        item = Bonbon.Repo.insert!(IngredientList.changeset(@valid_model, %{ food_id: food.id, ingredient_id: ingredient.id }))

        assert_change(@valid_model, %{ food_id: food.id, ingredient_id: ingredient.id })
        |> assert_insert(:error)
        |> assert_error_value(:food_id_ingredient_id, { "has already been taken", [] })

        food2 = Bonbon.Repo.insert!(Bonbon.Model.Item.Food.changeset(%Bonbon.Model.Item.Food{}, %{ content: 2, available: true, price: Decimal.new(1), currency: "AUD", image: "image.jpg" }))
        ingredient2 = Bonbon.Repo.insert!(Bonbon.Model.Ingredient.changeset(%Bonbon.Model.Ingredient{}, %{ name: 2, type: 1 }))

        assert_change(@valid_model, %{ food_id: food2.id, ingredient_id: ingredient.id })
        |> assert_insert(:ok)

        assert_change(@valid_model, %{ food_id: food.id, ingredient_id: ingredient2.id })
        |> assert_insert(:ok)

        food3 = Bonbon.Repo.insert!(Bonbon.Model.Item.Food.changeset(%Bonbon.Model.Item.Food{}, %{ content: 3, available: true, price: Decimal.new(1), currency: "AUD", image: "image.jpg" }))
        ingredient3 = Bonbon.Repo.insert!(Bonbon.Model.Ingredient.changeset(%Bonbon.Model.Ingredient{}, %{ name: 3, type: 1 }))

        assert_change(@valid_model, %{ food_id: food3.id, ingredient_id: ingredient3.id })
        |> assert_insert(:ok)
    end
end
