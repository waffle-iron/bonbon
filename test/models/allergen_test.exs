defmodule Bonbon.AllergenTest do
    use Bonbon.ModelCase
    use Translecto.Query

    alias Bonbon.Allergen

    @valid_model %Allergen{ name: 1 }

    test "empty" do
        refute_change(%Allergen{})
    end

    test "only name" do
        assert_change(%Allergen{}, %{ name: 1 })
    end

    test "uniqueness" do
        name = Bonbon.Repo.insert!(@valid_model)

        assert_change(%Allergen{}, %{ name: @valid_model.name })
        |> assert_insert(:error)
        |> assert_error_value(:name, { "has already been taken", [] })

        assert_change(%Allergen{}, %{ name: @valid_model.name + 1 })
        |> assert_insert(:ok)
    end

    test "translation" do
        en = Bonbon.Repo.insert!(%Bonbon.Locale{ language: "en" })
        fr = Bonbon.Repo.insert!(%Bonbon.Locale{ language: "fr" })
        en_peanut = Bonbon.Repo.insert!(Allergen.Name.Translation.changeset(%Allergen.Name.Translation{}, %{ translate_id: 1, locale_id: en.id, term: "peanut allergy" }))
        fr_peanut = Bonbon.Repo.insert!(Allergen.Name.Translation.changeset(%Allergen.Name.Translation{}, %{ translate_id: 1, locale_id: fr.id, term: "allergie à l'arachide" }))
        en_fish = Bonbon.Repo.insert!(Allergen.Name.Translation.changeset(%Allergen.Name.Translation{}, %{ translate_id: 2, locale_id: en.id, term: "fish allergy" }))
        fr_fish = Bonbon.Repo.insert!(Allergen.Name.Translation.changeset(%Allergen.Name.Translation{}, %{ translate_id: 2, locale_id: fr.id, term: "allergie au poisson" }))

        allergen_peanut = Bonbon.Repo.insert!(Allergen.changeset(%Allergen{}, %{ name: en_peanut.translate_id }))
        allergen_fish = Bonbon.Repo.insert!(Allergen.changeset(%Allergen{}, %{ name: en_fish.translate_id }))

        query = from allergen in Allergen,
            locale: ^en.id,
            translate: name in allergen.name,
            select: name.term

        assert Bonbon.Repo.all(query) == ["peanut allergy", "fish allergy"]

        query = from allergen in Allergen,
            locale: ^fr.id,
            translate: name in allergen.name,
            select: name.term

        assert Bonbon.Repo.all(query) == ["allergie à l'arachide", "allergie au poisson"]

        query = from allergen in Allergen,
            locale: ^fr.id,
            translate: name in allergen.name, where: name.term == "allergie au poisson",
            select: name.term

        assert Bonbon.Repo.all(query) == ["allergie au poisson"]
    end
end
