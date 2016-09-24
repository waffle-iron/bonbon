defmodule Bonbon.API.Cuisine.RegionTest do
    use Bonbon.APICase

    setup %{ conn: conn } do
        en = Bonbon.Repo.insert!(%Bonbon.Model.Locale{ language: "en" })
        fr = Bonbon.Repo.insert!(%Bonbon.Model.Locale{ language: "fr" })

        en_continent = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.Continent.Translation.changeset(%Bonbon.Model.Cuisine.Region.Continent.Translation{}, %{ translate_id: 1, locale_id: en.id, term: "africa" }))
        fr_continent = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.Continent.Translation.changeset(%Bonbon.Model.Cuisine.Region.Continent.Translation{}, %{ translate_id: 1, locale_id: fr.id, term: "afrique" }))
        en_subregion = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.Subregion.Translation.changeset(%Bonbon.Model.Cuisine.Region.Subregion.Translation{}, %{ translate_id: 1, locale_id: en.id, term: "central africa" }))
        fr_subregion = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.Subregion.Translation.changeset(%Bonbon.Model.Cuisine.Region.Subregion.Translation{}, %{ translate_id: 1, locale_id: fr.id, term: "afrique centrale" }))
        en_country = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.Country.Translation.changeset(%Bonbon.Model.Cuisine.Region.Country.Translation{}, %{ translate_id: 1, locale_id: en.id, term: "gabon" }))
        fr_country = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.Country.Translation.changeset(%Bonbon.Model.Cuisine.Region.Country.Translation{}, %{ translate_id: 1, locale_id: fr.id, term: "gabon" }))
        en_province = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.Province.Translation.changeset(%Bonbon.Model.Cuisine.Region.Province.Translation{}, %{ translate_id: 1, locale_id: en.id, term: "estuaire" }))
        fr_province = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.Province.Translation.changeset(%Bonbon.Model.Cuisine.Region.Province.Translation{}, %{ translate_id: 1, locale_id: fr.id, term: "estuaire" }))

        region_africa = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.changeset(%Bonbon.Model.Cuisine.Region{}, %{ continent: en_continent.translate_id }))
        region_central_africa = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.changeset(%Bonbon.Model.Cuisine.Region{}, %{ continent: en_continent.translate_id, subregion: en_subregion.translate_id }))
        region_gabon = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.changeset(%Bonbon.Model.Cuisine.Region{}, %{ continent: en_continent.translate_id, subregion: en_subregion.translate_id, country: en_country.translate_id }))
        region_estuaire = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.changeset(%Bonbon.Model.Cuisine.Region{}, %{ continent: en_continent.translate_id, subregion: en_subregion.translate_id, country: en_country.translate_id, province: en_province.translate_id }))

        db = %{
            en: %{
                region: %{
                    estuaire: %{ "id" => to_string(region_estuaire.id), "continent" => en_continent.term, "subregion" => en_subregion.term, "country" => en_country.term, "province" => en_province.term },
                    gabon: %{ "id" => to_string(region_gabon.id), "continent" => en_continent.term, "subregion" => en_subregion.term, "country" => en_country.term, "province" => nil },
                    central_africa: %{ "id" => to_string(region_central_africa.id), "continent" => en_continent.term, "subregion" => en_subregion.term, "country" => nil, "province" => nil },
                    africa: %{ "id" => to_string(region_africa.id), "continent" => en_continent.term, "subregion" => nil, "country" => nil, "province" => nil }
                }
            },
            fr: %{
                region: %{
                    estuaire: %{ "id" => to_string(region_estuaire.id), "continent" => fr_continent.term, "subregion" => fr_subregion.term, "country" => fr_country.term, "province" => fr_province.term },
                    gabon: %{ "id" => to_string(region_gabon.id), "continent" => fr_continent.term, "subregion" => fr_subregion.term, "country" => fr_country.term, "province" => nil },
                    central_africa: %{ "id" => to_string(region_central_africa.id), "continent" => fr_continent.term, "subregion" => fr_subregion.term, "country" => nil, "province" => nil },
                    africa: %{ "id" => to_string(region_africa.id), "continent" => fr_continent.term, "subregion" => nil, "country" => nil, "province" => nil }
                }
            }
        }

        { :ok, %{ conn: conn, db: db } }
    end

    #region
    @root :region
    @fields [:id, :continent, :subregion, :country, :province]

    @tag locale: "en"
    test "get region without id", %{ conn: conn } do
        assert "1 required argument (`id') not provided" == query_error(conn) #todo: possibly just check that an error was returned
    end

    #region(id:)
    test_localisable_query("get region with invalid id", nil, id: 0)

    test_localisable_query("get region with id", &(&2[&1].region.gabon), id: &(&1.en.region.gabon["id"]))

    @tag locale: "en"
    test "get region with non-integer id", %{ conn: conn } do
        assert _ = query_error(conn, id: "test") #todo: change to custom formatted message
    end

    #regions
    @root :regions

    test_localisable_query("list all regions", &([&2[&1].region.africa, &2[&1].region.central_africa, &2[&1].region.gabon, &2[&1].region.estuaire]))

    test_localisable_query("list first region", &([&2[&1].region.africa]), limit: 1)

    test_localisable_query("list second region", &([&2[&1].region.central_africa]), limit: 1, offset: 1)

    @tag locale: "en"
    test "list regions with negative limit", %{ conn: conn } do
        assert "LIMIT must not be negative" == query_error(conn, limit: -1) #todo: change to custom formatted message
    end

    @tag locale: "en"
    test "list regions with negative offset", %{ conn: conn } do
        assert "OFFSET must not be negative" == query_error(conn, offset: -1) #todo: change to custom formatted message
    end

    @tag locale: "en"
    test "list regions with non-integer limit", %{ conn: conn } do
        assert "1 badly formed argument (`limit') provided" == query_error(conn, limit: "test") #todo: possibly just check that an error was returned
    end

    @tag locale: "en"
    test "list regions with non-integer offset", %{ conn: conn } do
        assert "1 badly formed argument (`offset') provided" == query_error(conn, offset: "test") #todo: possibly just check that an error was returned
    end

    #regions(find:)
    test_localisable_query("find 'afric' in regions", fn
        :en, db -> [db.en.region.africa, db.en.region.central_africa, db.en.region.gabon, db.en.region.estuaire]
        :fr, _ -> []
    end, find: "afric")

    test_localisable_query("find 'afrique' in regions", fn
        :en, _ -> []
        :fr, db -> [db.fr.region.africa, db.fr.region.central_africa, db.fr.region.gabon, db.fr.region.estuaire]
    end, find: "afrique")

    test_localisable_query("find 'af' in regions", &([&2[&1].region.africa, &2[&1].region.central_africa, &2[&1].region.gabon, &2[&1].region.estuaire]), find: "af")

    test_localisable_query("find 'gab' in regions", &([&2[&1].region.gabon, &2[&1].region.estuaire]), find: "gab")

    test_localisable_query("find 'zz' in regions", [], find: "zz")

    #regions(continent:)
    test_localisable_query("find continent 'afric' in regions", fn
        :en, db -> [db.en.region.africa, db.en.region.central_africa, db.en.region.gabon, db.en.region.estuaire]
        :fr, _ -> []
    end, continent: "afric")

    test_localisable_query("find continent 'afrique' in regions", fn
        :en, _ -> []
        :fr, db -> [db.fr.region.africa, db.fr.region.central_africa, db.fr.region.gabon, db.fr.region.estuaire]
    end, continent: "afrique")

    test_localisable_query("find continent 'af' in regions", &([&2[&1].region.africa, &2[&1].region.central_africa, &2[&1].region.gabon, &2[&1].region.estuaire]), continent: "af")

    test_localisable_query("find continent 'gab' in regions", [], continent: "gab")

    test_localisable_query("find continent 'zz' in regions", [], continent: "zz")

    #regions(subregion:)
    test_localisable_query("find subregion 'afric' in regions", [], subregion: "afric")

    test_localisable_query("find subregion 'afrique' in regions", fn
        :en, _ -> []
        :fr, db -> [db.fr.region.central_africa, db.fr.region.gabon, db.fr.region.estuaire]
    end, subregion: "afrique")

    test_localisable_query("find subregion 'af' in regions", fn
        :en, _ -> []
        :fr, db -> [db.fr.region.central_africa, db.fr.region.gabon, db.fr.region.estuaire]
    end, subregion: "af")

    test_localisable_query("find subregion 'gab' in regions", [], subregion: "gab")

    test_localisable_query("find subregion 'zz' in regions", [], subregion: "zz")

    #regions(country:)
    test_localisable_query("find country 'afric' in regions", [], country: "afric")

    test_localisable_query("find country 'afrique' in regions", [], country: "afrique")

    test_localisable_query("find country 'af' in regions", [], country: "af")

    test_localisable_query("find country 'gab' in regions", &([&2[&1].region.gabon, &2[&1].region.estuaire]), country: "gab")

    test_localisable_query("find country 'zz' in regions", [], country: "zz")

    #regions(province:)
    test_localisable_query("find province 'afric' in regions", [], province: "afric")

    test_localisable_query("find province 'afrique' in regions", [], province: "afrique")

    test_localisable_query("find province 'af' in regions", [], province: "af")

    test_localisable_query("find province 'gab' in regions", [], province: "gab")

    test_localisable_query("find province 'es' in regions", &([&2[&1].region.estuaire]), province: "es")

    test_localisable_query("find province 'zz' in regions", [], province: "zz")

    #ingredients(continent:, subregion:, country:, province:, find:)
    test_localisable_query("find 'af' continent 'afriq', subregion 'c', country 'g', province 'e' in regions", [], find: "af", continent: "afriq", subregion: "c", country: "g", province: "e")

    test_localisable_query("find 'af' continent 'a', subregion 'c', country 'g', province 'e' in regions", fn
        :en, db -> [db.en.region.estuaire]
        :fr, _ -> []
    end, find: "af", continent: "a", subregion: "c", country: "g", province: "e")

    test_localisable_query("find 'af' continent 'a', subregion 'a', country 'g', province 'e' in regions", fn
        :en, _ -> []
        :fr, db -> [db.fr.region.estuaire]
    end, find: "af", continent: "a", subregion: "a", country: "g", province: "e")
end
