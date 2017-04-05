defmodule Bonbon.Model.Item.Food.AllergenListTest do
    use Bonbon.ModelCase

    alias Bonbon.Model.Item.Food.AllergenList

    @valid_model %AllergenList{
        food_id: 1,
        allergen_id: 1,
    }

    test "empty" do
        refute_change(%AllergenList{})
    end

    test "only food_id" do
        refute_change(%AllergenList{}, %{ food_id: 1 })
    end

    test "only allergen_id" do
        refute_change(%AllergenList{}, %{ allergen_id: 1 })
    end

    test "without food_id" do
        refute_change(@valid_model, %{ food_id: nil })
    end

    test "without allergen_id" do
        refute_change(@valid_model, %{ allergen_id: nil })
    end

    test "uniqueness" do
        food = Bonbon.Repo.insert!(Bonbon.Model.Item.Food.changeset(%Bonbon.Model.Item.Food{}, %{ content: 1, available: true, price: Decimal.new(1), currency: "AUD", image: "image.jpg" }))
        ingredient = Bonbon.Repo.insert!(Bonbon.Model.Allergen.changeset(%Bonbon.Model.Allergen{}, %{ name: 1 }))
        item = Bonbon.Repo.insert!(AllergenList.changeset(@valid_model, %{ food_id: food.id, allergen_id: ingredient.id }))

        assert_change(@valid_model, %{ food_id: food.id, allergen_id: ingredient.id })
        |> assert_insert(:error)
        |> assert_error_value(:food_id_allergen_id, { "has already been taken", [] })

        food2 = Bonbon.Repo.insert!(Bonbon.Model.Item.Food.changeset(%Bonbon.Model.Item.Food{}, %{ content: 2, available: true, price: Decimal.new(1), currency: "AUD", image: "image.jpg" }))
        ingredient2 = Bonbon.Repo.insert!(Bonbon.Model.Allergen.changeset(%Bonbon.Model.Allergen{}, %{ name: 2 }))

        assert_change(@valid_model, %{ food_id: food2.id, allergen_id: ingredient.id })
        |> assert_insert(:ok)

        assert_change(@valid_model, %{ food_id: food.id, allergen_id: ingredient2.id })
        |> assert_insert(:ok)

        food3 = Bonbon.Repo.insert!(Bonbon.Model.Item.Food.changeset(%Bonbon.Model.Item.Food{}, %{ content: 3, available: true, price: Decimal.new(1), currency: "AUD", image: "image.jpg" }))
        ingredient3 = Bonbon.Repo.insert!(Bonbon.Model.Allergen.changeset(%Bonbon.Model.Allergen{}, %{ name: 3 }))

        assert_change(@valid_model, %{ food_id: food3.id, allergen_id: ingredient3.id })
        |> assert_insert(:ok)
    end
end
