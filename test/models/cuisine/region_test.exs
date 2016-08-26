defmodule Bonbon.Cuisine.RegionTest do
    use Bonbon.ModelCase
    use Translecto.Query

    alias Bonbon.Cuisine.Region

    @valid_model %Region{ continent: 1 }

    test "empty" do
        refute_change(%Region{})
    end

    test "only continent" do
        assert_change(%Region{}, %{ continent: 1 })
    end

    test "only subregion" do
        refute_change(%Region{}, %{ subregion: 1 })
    end

    test "only country" do
        refute_change(%Region{}, %{ country: 1 })
    end

    test "only province" do
        refute_change(%Region{}, %{ province: 1 })
    end

    test "without continent" do
        refute_change(%Region{}, %{ subregion: 1, country: 1, province: 1 })
    end

    test "without subregion" do
        assert_change(%Region{}, %{ continent: 1, country: 1, province: 1 })
    end

    test "without country" do
        assert_change(%Region{}, %{ continent: 1, subregion: 1, province: 1 })
    end

    test "without province" do
        assert_change(%Region{}, %{ continent: 1, subregion: 1, country: 1 })
    end

    test "uniqueness" do
        name = Bonbon.Repo.insert!(@valid_model)

        assert_change(@valid_model)
        |> assert_insert(:error)
        |> assert_error_value(:region, { "has already been taken", [] })

        for continent <- (@valid_model.continent + 1)..2,
            subregion <- [nil, 1],
            country <- [nil, 1],
            province <- [nil, 1] do
                assert_change(%Region{}, %{ continent: continent, subregion: subregion, country: country, province: province })
                |> assert_insert(:ok)
        end

        for continent <- (@valid_model.continent + 1)..2,
            subregion <- [nil, 1],
            country <- [nil, 1],
            province <- [nil, 1] do
                assert_change(%Region{}, %{ continent: continent, subregion: subregion, country: country, province: province })
                |> assert_insert(:error)
                |> assert_error_value(:region, { "has already been taken", [] })
        end
    end

    test "translation" do
        en = Bonbon.Repo.insert!(%Bonbon.Locale{ language: "en" })
        fr = Bonbon.Repo.insert!(%Bonbon.Locale{ language: "fr" })
        en_continent = Bonbon.Repo.insert!(Region.Continent.Translation.changeset(%Region.Continent.Translation{}, %{ translate_id: 1, locale_id: en.id, term: "africa" }))
        fr_continent = Bonbon.Repo.insert!(Region.Continent.Translation.changeset(%Region.Continent.Translation{}, %{ translate_id: 1, locale_id: fr.id, term: "afrique" }))
        en_subregion = Bonbon.Repo.insert!(Region.Subregion.Translation.changeset(%Region.Subregion.Translation{}, %{ translate_id: 1, locale_id: en.id, term: "central africa" }))
        fr_subregion = Bonbon.Repo.insert!(Region.Subregion.Translation.changeset(%Region.Subregion.Translation{}, %{ translate_id: 1, locale_id: fr.id, term: "afrique centrale" }))
        en_country = Bonbon.Repo.insert!(Region.Country.Translation.changeset(%Region.Country.Translation{}, %{ translate_id: 1, locale_id: en.id, term: "gabon" }))
        fr_country = Bonbon.Repo.insert!(Region.Country.Translation.changeset(%Region.Country.Translation{}, %{ translate_id: 1, locale_id: fr.id, term: "gabon" }))
        en_province = Bonbon.Repo.insert!(Region.Province.Translation.changeset(%Region.Province.Translation{}, %{ translate_id: 1, locale_id: en.id, term: "estuaire" }))
        fr_province = Bonbon.Repo.insert!(Region.Province.Translation.changeset(%Region.Province.Translation{}, %{ translate_id: 1, locale_id: fr.id, term: "estuaire" }))

        region = Bonbon.Repo.insert!(Region.changeset(%Region{}, %{ continent: en_continent.translate_id, subregion: en_subregion.translate_id, country: en_country.translate_id, province: en_province.translate_id }))

        query = from region in Region,
            locale: ^en.id,
            translate: continent in region.continent,
            translate: subregion in region.subregion,
            translate: country in region.country,
            translate: province in region.province,
            select: { continent.term, subregion.term, country.term, province.term }

        assert Bonbon.Repo.all(query) == [{ "africa", "central africa", "gabon", "estuaire" }]

        query = from region in Region,
            locale: ^fr.id,
            translate: continent in region.continent,
            translate: subregion in region.subregion,
            translate: country in region.country,
            translate: province in region.province,
            select: { continent.term, subregion.term, country.term, province.term }

        assert Bonbon.Repo.all(query) == [{ "afrique", "afrique centrale", "gabon", "estuaire" }]

        query = from region in Region,
            locale: ^fr.id,
            translate: country in region.country, where: country.term == "gabon",
            translate: continent in region.continent,
            select: continent.term

        assert Bonbon.Repo.all(query) == ["afrique"]
    end
end
