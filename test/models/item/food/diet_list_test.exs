defmodule Bonbon.Model.Item.Food.DietListTest do
    use Bonbon.ModelCase

    alias Bonbon.Model.Item.Food.DietList

    @valid_model %DietList{ food_id: 1, diet_id: 1 }

    test "empty" do
        refute_change(%DietList{})
    end

    test "only food_id" do
        refute_change(%DietList{}, %{ food_id: 1 })
    end

    test "only diet_id" do
        refute_change(%DietList{}, %{ diet_id: 1 })
    end

    test "without food_id" do
        refute_change(@valid_model, %{ food_id: nil })
    end

    test "without diet_id" do
        refute_change(@valid_model, %{ diet_id: nil })
    end

    test "uniqueness" do
        food = Bonbon.Repo.insert!(Bonbon.Model.Item.Food.changeset(%Bonbon.Model.Item.Food{}, %{ content: 1, available: true, price: Decimal.new(1), currency: "AUD", image: "image.jpg" }))
        diet = Bonbon.Repo.insert!(Bonbon.Model.Diet.changeset(%Bonbon.Model.Diet{}, %{ name: 1 }))
        item = Bonbon.Repo.insert!(DietList.changeset(@valid_model, %{ food_id: food.id, diet_id: diet.id }))

        assert_change(@valid_model, %{ food_id: food.id, diet_id: diet.id })
        |> assert_insert(:error)
        |> assert_error_value(:food_id_diet_id, { "has already been taken", [] })

        food2 = Bonbon.Repo.insert!(Bonbon.Model.Item.Food.changeset(%Bonbon.Model.Item.Food{}, %{ content: 2, available: true, price: Decimal.new(1), currency: "AUD", image: "image.jpg" }))
        diet2 = Bonbon.Repo.insert!(Bonbon.Model.Diet.changeset(%Bonbon.Model.Diet{}, %{ name: 2 }))

        assert_change(@valid_model, %{ food_id: food2.id, diet_id: diet.id })
        |> assert_insert(:ok)

        assert_change(@valid_model, %{ food_id: food.id, diet_id: diet2.id })
        |> assert_insert(:ok)

        food3 = Bonbon.Repo.insert!(Bonbon.Model.Item.Food.changeset(%Bonbon.Model.Item.Food{}, %{ content: 3, available: true, price: Decimal.new(1), currency: "AUD", image: "image.jpg" }))
        diet3 = Bonbon.Repo.insert!(Bonbon.Model.Diet.changeset(%Bonbon.Model.Diet{}, %{ name: 3 }))

        assert_change(@valid_model, %{ food_id: food3.id, diet_id: diet3.id })
        |> assert_insert(:ok)
    end
end
