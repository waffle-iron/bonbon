defmodule Bonbon.Model.Item.FoodTest do
    use Bonbon.ModelCase
    use Translecto.Query

    alias Bonbon.Model.Item.Food

    @valid_model %Food{
        content: 1,
        prep_time: 1,
        available: true,
        cuisine_id: nil,
        calories: 1,
        price: Decimal.new(1),
        currency: "AUD",
        image: "https://example.com/food.jpg"
    }

    test "empty" do
        refute_change(%Food{})
    end

    test "only content" do
        refute_change(%Food{}, %{ content: 1 })
    end

    test "only prep_time" do
        refute_change(%Food{}, %{ prep_time: 1 })
    end

    test "only available" do
        refute_change(%Food{}, %{ available: true })
    end

    test "only cuisine_id" do
        refute_change(%Food{}, %{ cuisine_id: 1 })
    end

    test "only calories" do
        refute_change(%Food{}, %{ calories: 1 })
    end

    test "only price" do
        refute_change(%Food{}, %{ price: Decimal.new(1) })
    end

    test "only currency" do
        refute_change(%Food{}, %{ currency: "AUD" })
    end

    test "only image" do
        refute_change(%Food{}, %{ image: "https://example.com/food.jpg" })
    end

    test "without content" do
        refute_change(@valid_model, %{ content: nil })
    end

    test "without prep_time" do
        assert_change(@valid_model, %{ prep_time: nil })
    end

    test "without available" do
        refute_change(@valid_model, %{ available: nil })
    end

    test "without cuisine_id" do
        assert_change(@valid_model, %{ cuisine_id: nil })
    end

    test "without calories" do
        assert_change(@valid_model, %{ calories: nil })
    end

    test "without price" do
        refute_change(@valid_model, %{ price: nil })
    end

    test "without currency" do
        refute_change(@valid_model, %{ currency: nil })
    end

    test "without image" do
        refute_change(@valid_model, %{ image: nil })
    end

    test "currency length" do
        refute_change(@valid_model, %{ currency: "" })
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
        name = Bonbon.Repo.insert!(@valid_model)

        assert_change(@valid_model, %{ content: @valid_model.content })
        |> assert_insert(:error)
        |> assert_error_value(:content, { "has already been taken", [] })

        assert_change(@valid_model, %{ content: @valid_model.content + 1 })
        |> assert_insert(:ok)
    end

    test "translation" do
        en = Bonbon.Repo.insert!(%Bonbon.Model.Locale{ language: "en" })
        fr = Bonbon.Repo.insert!(%Bonbon.Model.Locale{ language: "fr" })
        en_content = Bonbon.Repo.insert!(Food.Content.Translation.changeset(%Food.Content.Translation{}, %{ translate_id: 1, locale_id: en.id, name: "Hamburger", description: "A hamburger" }))
        fr_contnet = Bonbon.Repo.insert!(Food.Content.Translation.changeset(%Food.Content.Translation{}, %{ translate_id: 1, locale_id: fr.id, name: "Hamburger", description: "Un hamburger" }))

        food_hamburger = Bonbon.Repo.insert!(Food.changeset(@valid_model, %{ content: en_content.translate_id }))

        query = from food in Food,
            locale: ^en.id,
            translate: content in food.content,
            select: { content.name, content.description }

        assert Bonbon.Repo.all(query) == [{ "Hamburger", "A hamburger" }]

        query = from food in Food,
            locale: ^fr.id,
            translate: content in food.content,
            select: { content.name, content.description }

        assert Bonbon.Repo.all(query) == [{ "Hamburger", "Un hamburger" }]

        query = from food in Food,
            locale: ^fr.id,
            translate: content in food.content, where: content.name == "Hamburger",
            select: content.description

        assert Bonbon.Repo.all(query) == ["Un hamburger"]
    end
end
