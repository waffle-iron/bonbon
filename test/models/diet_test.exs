defmodule Bonbon.DietTest do
    use Bonbon.ModelCase
    use Translecto.Query

    alias Bonbon.Diet

    @valid_model %Diet{ name: 1 }

    test "empty" do
        refute_change(%Diet{})
    end

    test "only name" do
        assert_change(%Diet{}, %{ name: 1 })
    end

    test "uniqueness" do
        name = Bonbon.Repo.insert!(@valid_model)

        assert_change(%Diet{}, %{ name: @valid_model.name })
        |> assert_insert(:error)
        |> assert_error_value(:name, { "has already been taken", [] })

        assert_change(%Diet{}, %{ name: @valid_model.name + 1 })
        |> assert_insert(:ok)
    end

    test "translation" do
        en = Bonbon.Repo.insert!(%Bonbon.Locale{ language: "en" })
        fr = Bonbon.Repo.insert!(%Bonbon.Locale{ language: "fr" })
        en_vegan = Bonbon.Repo.insert!(Diet.Name.Translation.changeset(%Diet.Name.Translation{}, %{ translate_id: 1, locale_id: en.id, term: "vegan" }))
        fr_vegan = Bonbon.Repo.insert!(Diet.Name.Translation.changeset(%Diet.Name.Translation{}, %{ translate_id: 1, locale_id: fr.id, term: "végétalien" }))
        en_vegetarian = Bonbon.Repo.insert!(Diet.Name.Translation.changeset(%Diet.Name.Translation{}, %{ translate_id: 2, locale_id: en.id, term: "vegetarian" }))
        fr_vegetarian = Bonbon.Repo.insert!(Diet.Name.Translation.changeset(%Diet.Name.Translation{}, %{ translate_id: 2, locale_id: fr.id, term: "végétarien" }))

        diet_vegan = Bonbon.Repo.insert!(Diet.changeset(%Diet{}, %{ name: en_vegan.translate_id }))
        diet_vegetarian = Bonbon.Repo.insert!(Diet.changeset(%Diet{}, %{ name: en_vegetarian.translate_id }))

        query = from diet in Diet,
            locale: ^en.id,
            translate: name in diet.name,
            select: name.term

        assert Bonbon.Repo.all(query) == ["vegan", "vegetarian"]

        query = from diet in Diet,
            locale: ^fr.id,
            translate: name in diet.name,
            select: name.term

        assert Bonbon.Repo.all(query) == ["végétalien", "végétarien"]

        query = from diet in Diet,
            locale: ^fr.id,
            translate: name in diet.name, where: name.term == "végétarien",
            select: name.term

        assert Bonbon.Repo.all(query) == ["végétarien"]
    end
end
