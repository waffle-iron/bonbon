defmodule Bonbon.IngredientTest do
    use Bonbon.ModelCase
    use Translecto.Query

    alias Bonbon.Ingredient

    @valid_model %Ingredient{ type: 1, name: 1 }

    test "empty" do
        refute_change(%Ingredient{})
    end

    test "only type" do
        refute_change(%Ingredient{}, %{ type: 1 })
    end

    test "only name" do
        assert_change(%Ingredient{}, %{ name: 1 })
    end

    test "uniqueness" do
        name = Bonbon.Repo.insert!(@valid_model)

        assert_change(%Ingredient{}, %{ type: @valid_model.type + 1, name: @valid_model.name })
        |> assert_insert(:error)
        |> assert_error_value(:name, { "has already been taken", [] })

        assert_change(%Ingredient{}, %{ type: @valid_model.type, name: @valid_model.name + 1 })
        |> assert_insert(:ok)

        assert_change(%Ingredient{}, %{ type: @valid_model.type + 1, name: @valid_model.name + 1 })
        |> assert_insert(:ok)
    end

    test "translation" do
        en = Bonbon.Repo.insert!(%Bonbon.Locale{ language: "en" })
        fr = Bonbon.Repo.insert!(%Bonbon.Locale{ language: "fr" })
        en_fruit = Bonbon.Repo.insert!(Ingredient.Type.Translation.changeset(%Ingredient.Type.Translation{}, %{ translate_id: 1, locale_id: en.id, term: "fruit" }))
        fr_fruit = Bonbon.Repo.insert!(Ingredient.Type.Translation.changeset(%Ingredient.Type.Translation{}, %{ translate_id: 1, locale_id: fr.id, term: "fruit" }))
        en_apple = Bonbon.Repo.insert!(Ingredient.Name.Translation.changeset(%Ingredient.Name.Translation{}, %{ translate_id: 1, locale_id: en.id, term: "apple" }))
        fr_apple = Bonbon.Repo.insert!(Ingredient.Name.Translation.changeset(%Ingredient.Name.Translation{}, %{ translate_id: 1, locale_id: fr.id, term: "pomme" }))
        en_lemon = Bonbon.Repo.insert!(Ingredient.Name.Translation.changeset(%Ingredient.Name.Translation{}, %{ translate_id: 2, locale_id: en.id, term: "lemon" }))
        fr_lemon = Bonbon.Repo.insert!(Ingredient.Name.Translation.changeset(%Ingredient.Name.Translation{}, %{ translate_id: 2, locale_id: fr.id, term: "citron" }))

        ingredient_apple = Bonbon.Repo.insert!(Ingredient.changeset(%Ingredient{}, %{ type: en_fruit.translate_id, name: en_apple.translate_id }))
        ingredient_lemon = Bonbon.Repo.insert!(Ingredient.changeset(%Ingredient{}, %{ type: en_fruit.translate_id, name: en_lemon.translate_id }))

        query = from ingredient in Ingredient,
            locale: ^en.id,
            translate: name in ingredient.name,
            translate: type in ingredient.type,
            select: { name.term, type.term }

        assert Bonbon.Repo.all(query) == [{ "apple", "fruit" }, { "lemon", "fruit" }]

        query = from ingredient in Ingredient,
            locale: ^fr.id,
            translate: name in ingredient.name,
            translate: type in ingredient.type,
            select: { name.term, type.term }

        assert Bonbon.Repo.all(query) == [{ "pomme", "fruit" }, { "citron", "fruit" }]

        query = from ingredient in Ingredient,
            locale: ^fr.id,
            translate: name in ingredient.name, where: name.term == "citron",
            translate: type in ingredient.type,
            select: type.term

        assert Bonbon.Repo.all(query) == ["fruit"]
    end
end
