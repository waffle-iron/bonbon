defmodule Bonbon.IngredientNameTranslationTest do
    use Bonbon.ModelCase

    alias Bonbon.IngredientNameTranslation

    @valid_model %IngredientNameTranslation{ locale_id: 1, term: "lemon" }

    test "empty" do
        refute_change(%IngredientNameTranslation{})
    end

    test "only locale" do
        refute_change(%IngredientNameTranslation{}, %{ locale_id: 1 })
    end

    test "only translate" do
        refute_change(%IngredientNameTranslation{}, %{ translate_id: 1 })
    end

    test "only term" do
        refute_change(%IngredientNameTranslation{}, %{ term: "lemon" })
    end

    test "without locale" do
        refute_change(%IngredientNameTranslation{}, %{ translate_id: 1, term: "lemon" })
    end

    test "without translate" do
        assert_change(%IngredientNameTranslation{}, %{ locale_id: 1, term: "lemon" })
        |> assert_change_value(:locale_id, 1)
        |> assert_change_value(:term, "lemon")
    end

    test "without term" do
        refute_change(%IngredientNameTranslation{}, %{ locale_id: 1, translate_id: 1 })
    end

    test "term casing" do
        assert_change(@valid_model, %{ term: "orange" }) |> assert_change_value(:term, "orange")
        assert_change(@valid_model, %{ term: "Orange" }) |> assert_change_value(:term, "orange")
        assert_change(@valid_model, %{ term: "orangE" }) |> assert_change_value(:term, "orange")
        assert_change(@valid_model, %{ term: "ORANGE" }) |> assert_change_value(:term, "orange")
    end

    test "uniqueness" do
        en = Bonbon.Repo.insert!(%Bonbon.Locale{ language: "en" })
        fr = Bonbon.Repo.insert!(%Bonbon.Locale{ language: "fr" })
        name = Bonbon.Repo.insert!(IngredientNameTranslation.changeset(@valid_model, %{ locale_id: en.id }))

        assert_change(%IngredientNameTranslation{}, %{ locale_id: fr.id + 1, term: "orange" })
        |> assert_insert(:error)
        |> assert_error_value(:locale, { "does not exist", [] })

        assert_change(%IngredientNameTranslation{}, %{ locale_id: en.id, term: "orange", translate_id: name.translate_id })
        |> assert_insert(:error)
        |> assert_error_value(:ingredient_name_translations_pkey, { "has already been taken", [] })

        assert_change(%IngredientNameTranslation{}, %{ locale_id: fr.id, term: "orange", translate_id: name.translate_id })
        |> assert_insert(:ok)

        assert_change(%IngredientNameTranslation{}, %{ locale_id: en.id, term: "orange" })
        |> assert_insert(:ok)
    end
end
