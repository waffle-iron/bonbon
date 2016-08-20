defmodule Bonbon.IngredientTypeTranslationTest do
    use Bonbon.ModelCase

    alias Bonbon.IngredientTypeTranslation

    @valid_model %IngredientTypeTranslation{ locale_id: 1, term: "meat" }

    test "empty" do
        refute_change(%IngredientTypeTranslation{})
    end

    test "only locale" do
        refute_change(%IngredientTypeTranslation{}, %{ locale_id: 1 })
    end

    test "only translate" do
        refute_change(%IngredientTypeTranslation{}, %{ translate_id: 1 })
    end

    test "only term" do
        refute_change(%IngredientTypeTranslation{}, %{ term: "meat" })
    end

    test "without locale" do
        refute_change(%IngredientTypeTranslation{}, %{ translate_id: 1, term: "meat" })
    end

    test "without translate" do
        assert_change(%IngredientTypeTranslation{}, %{ locale_id: 1, term: "meat" })
        |> assert_change_value(:locale_id, 1)
        |> assert_change_value(:term, "meat")
    end

    test "without term" do
        refute_change(%IngredientTypeTranslation{}, %{ locale_id: 1, translate_id: 1 })
    end

    test "term casing" do
        assert_change(@valid_model, %{ term: "fruit" }) |> assert_change_value(:term, "fruit")
        assert_change(@valid_model, %{ term: "Fruit" }) |> assert_change_value(:term, "fruit")
        assert_change(@valid_model, %{ term: "fruiT" }) |> assert_change_value(:term, "fruit")
        assert_change(@valid_model, %{ term: "FRUIT" }) |> assert_change_value(:term, "fruit")
    end

    test "uniqueness" do
        en = Bonbon.Repo.insert!(%Bonbon.Locale{ language: "en" })
        fr = Bonbon.Repo.insert!(%Bonbon.Locale{ language: "fr" })
        name = Bonbon.Repo.insert!(IngredientTypeTranslation.changeset(@valid_model, %{ locale_id: en.id }))

        assert_change(%IngredientTypeTranslation{}, %{ locale_id: fr.id + 1, term: "fruit" })
        |> assert_insert(:error)
        |> assert_error_value(:locale, { "does not exist", [] })

        assert_change(%IngredientTypeTranslation{}, %{ locale_id: en.id, term: "fruit", translate_id: name.translate_id })
        |> assert_insert(:error)
        |> assert_error_value(:ingredient_type_translations_pkey, { "has already been taken", [] })

        assert_change(%IngredientTypeTranslation{}, %{ locale_id: fr.id, term: "fruit", translate_id: name.translate_id })
        |> assert_insert(:ok)

        assert_change(%IngredientTypeTranslation{}, %{ locale_id: en.id, term: "fruit" })
        |> assert_insert(:ok)
    end
end
