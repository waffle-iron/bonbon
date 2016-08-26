defmodule Bonbon.Model.CuisineTest do
    use Bonbon.ModelCase
    use Translecto.Query

    alias Bonbon.Model.Cuisine

    @valid_model %Cuisine{ name: 1, region_id: 1 }

    test "empty" do
        refute_change(%Cuisine{})
    end

    test "only name" do
        refute_change(%Cuisine{}, %{ name: 1 })
    end

    test "only region" do
        refute_change(%Cuisine{}, %{ region_id: 1 })
    end

    test "uniqueness" do
        en = Bonbon.Repo.insert!(%Bonbon.Model.Locale{ language: "en" })
        fr = Bonbon.Repo.insert!(%Bonbon.Model.Locale{ language: "fr" })
        en_continent = Bonbon.Repo.insert!(Cuisine.Region.Continent.Translation.changeset(%Cuisine.Region.Continent.Translation{}, %{ translate_id: 1, locale_id: en.id, term: "africa" }))
        fr_continent = Bonbon.Repo.insert!(Cuisine.Region.Continent.Translation.changeset(%Cuisine.Region.Continent.Translation{}, %{ translate_id: 1, locale_id: fr.id, term: "afrique" }))
        en_subregion = Bonbon.Repo.insert!(Cuisine.Region.Subregion.Translation.changeset(%Cuisine.Region.Subregion.Translation{}, %{ translate_id: 1, locale_id: en.id, term: "central africa" }))
        fr_subregion = Bonbon.Repo.insert!(Cuisine.Region.Subregion.Translation.changeset(%Cuisine.Region.Subregion.Translation{}, %{ translate_id: 1, locale_id: fr.id, term: "afrique centrale" }))
        en_country = Bonbon.Repo.insert!(Cuisine.Region.Country.Translation.changeset(%Cuisine.Region.Country.Translation{}, %{ translate_id: 1, locale_id: en.id, term: "gabon" }))
        fr_country = Bonbon.Repo.insert!(Cuisine.Region.Country.Translation.changeset(%Cuisine.Region.Country.Translation{}, %{ translate_id: 1, locale_id: fr.id, term: "gabon" }))
        en_province = Bonbon.Repo.insert!(Cuisine.Region.Province.Translation.changeset(%Cuisine.Region.Province.Translation{}, %{ translate_id: 1, locale_id: en.id, term: "estuaire" }))
        fr_province = Bonbon.Repo.insert!(Cuisine.Region.Province.Translation.changeset(%Cuisine.Region.Province.Translation{}, %{ translate_id: 1, locale_id: fr.id, term: "estuaire" }))

        region = Bonbon.Repo.insert!(Cuisine.Region.changeset(%Cuisine.Region{}, %{ continent: en_continent.translate_id, subregion: en_subregion.translate_id, country: en_country.translate_id, province: en_province.translate_id }))
        region2 = Bonbon.Repo.insert!(Cuisine.Region.changeset(%Cuisine.Region{}, %{ continent: en_continent.translate_id }))

        cuisine = Bonbon.Repo.insert!(Cuisine.changeset(@valid_model, %{ region_id: region.id }))

        assert_change(%Cuisine{}, %{ name: @valid_model.name + 1, region_id: region2.id + 1 })
        |> assert_insert(:error)
        |> assert_error_value(:region, { "does not exist", [] })

        assert_change(%Cuisine{}, %{ name: @valid_model.name, region_id: region.id })
        |> assert_insert(:error)
        |> assert_error_value(:name, { "has already been taken", [] })

        assert_change(%Cuisine{}, %{ name: @valid_model.name, region_id: region2.id })
        |> assert_insert(:error)
        |> assert_error_value(:name, { "has already been taken", [] })

        assert_change(%Cuisine{}, %{ name: @valid_model.name + 1, region_id: region.id })
        |> assert_insert(:ok)

        assert_change(%Cuisine{}, %{ name: @valid_model.name + 2, region_id: region2.id })
        |> assert_insert(:ok)
    end

    test "translation" do
        en = Bonbon.Repo.insert!(%Bonbon.Model.Locale{ language: "en" })
        fr = Bonbon.Repo.insert!(%Bonbon.Model.Locale{ language: "fr" })
        en_continent = Bonbon.Repo.insert!(Cuisine.Region.Continent.Translation.changeset(%Cuisine.Region.Continent.Translation{}, %{ translate_id: 1, locale_id: en.id, term: "europe" }))
        fr_continent = Bonbon.Repo.insert!(Cuisine.Region.Continent.Translation.changeset(%Cuisine.Region.Continent.Translation{}, %{ translate_id: 1, locale_id: fr.id, term: "europe" }))

        region = Bonbon.Repo.insert!(Cuisine.Region.changeset(%Cuisine.Region{}, %{ continent: en_continent.translate_id }))

        en_pasta = Bonbon.Repo.insert!(Cuisine.Name.Translation.changeset(%Cuisine.Name.Translation{}, %{ translate_id: 1, locale_id: en.id, term: "pasta" }))
        fr_pasta = Bonbon.Repo.insert!(Cuisine.Name.Translation.changeset(%Cuisine.Name.Translation{}, %{ translate_id: 1, locale_id: fr.id, term: "pâtes" }))

        cuisine_pasta = Bonbon.Repo.insert!(Cuisine.changeset(%Cuisine{}, %{ name: en_pasta.translate_id, region_id: region.id }))

        query = from cuisine in Cuisine,
            locale: ^en.id,
            translate: name in cuisine.name,
            join: region in Cuisine.Region, where: region.id == cuisine.region_id,
            translate: continent in region.continent,
            select: { name.term, continent.term }

        assert Bonbon.Repo.all(query) == [{ "pasta", "europe" }]

        query = from cuisine in Cuisine,
            locale: ^fr.id,
            translate: name in cuisine.name,
            join: region in Cuisine.Region, where: region.id == cuisine.region_id,
            translate: continent in region.continent,
            select: { name.term, continent.term }

        assert Bonbon.Repo.all(query) == [{ "pâtes", "europe" }]

        query = from cuisine in Cuisine,
            locale: ^fr.id,
            translate: name in cuisine.name, where: name.term == "pâtes",
            join: region in Cuisine.Region, where: region.id == cuisine.region_id,
            translate: continent in region.continent,
            select: continent.term

        assert Bonbon.Repo.all(query) == ["europe"]
    end
end
