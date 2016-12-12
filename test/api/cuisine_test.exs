defmodule Bonbon.API.CuisineTest do
    use Bonbon.APICase

    setup %{ conn: conn } do
        en = Bonbon.Repo.insert!(%Bonbon.Model.Locale{ language: "en" })
        fr = Bonbon.Repo.insert!(%Bonbon.Model.Locale{ language: "fr" })

        en_continent_oceania = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.Continent.Translation.changeset(%Bonbon.Model.Cuisine.Region.Continent.Translation{}, %{ translate_id: 1, locale_id: en.id, term: "oceanic" }))
        fr_continent_oceania = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.Continent.Translation.changeset(%Bonbon.Model.Cuisine.Region.Continent.Translation{}, %{ translate_id: 1, locale_id: fr.id, term: "océanique" }))
        en_subregion_australasia = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.Subregion.Translation.changeset(%Bonbon.Model.Cuisine.Region.Subregion.Translation{}, %{ translate_id: 1, locale_id: en.id, term: "australasian" }))
        fr_subregion_australasia = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.Subregion.Translation.changeset(%Bonbon.Model.Cuisine.Region.Subregion.Translation{}, %{ translate_id: 1, locale_id: fr.id, term: "australasian" }))
        en_country_australia = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.Country.Translation.changeset(%Bonbon.Model.Cuisine.Region.Country.Translation{}, %{ translate_id: 1, locale_id: en.id, term: "australia" }))
        fr_country_australia = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.Country.Translation.changeset(%Bonbon.Model.Cuisine.Region.Country.Translation{}, %{ translate_id: 1, locale_id: fr.id, term: "australie" }))
        en_province_brisbane = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.Province.Translation.changeset(%Bonbon.Model.Cuisine.Region.Province.Translation{}, %{ translate_id: 1, locale_id: en.id, term: "brisbane" }))
        fr_province_brisbane = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.Province.Translation.changeset(%Bonbon.Model.Cuisine.Region.Province.Translation{}, %{ translate_id: 1, locale_id: fr.id, term: "brisbane" }))

        en_continent_europe = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.Continent.Translation.changeset(%Bonbon.Model.Cuisine.Region.Continent.Translation{}, %{ translate_id: 2, locale_id: en.id, term: "europe" }))
        fr_continent_europe = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.Continent.Translation.changeset(%Bonbon.Model.Cuisine.Region.Continent.Translation{}, %{ translate_id: 2, locale_id: fr.id, term: "europe" }))

        region_europe = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.changeset(%Bonbon.Model.Cuisine.Region{}, %{ continent: en_continent_europe.translate_id }))
        region_brisbane = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.changeset(%Bonbon.Model.Cuisine.Region{}, %{ continent: en_continent_oceania.translate_id, subregion: en_subregion_australasia.translate_id, country: en_country_australia.translate_id, province: en_province_brisbane.translate_id }))

        en_pasta = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Name.Translation.changeset(%Bonbon.Model.Cuisine.Name.Translation{}, %{ translate_id: 1, locale_id: en.id, term: "pasta" }))
        fr_pasta = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Name.Translation.changeset(%Bonbon.Model.Cuisine.Name.Translation{}, %{ translate_id: 1, locale_id: fr.id, term: "pâtes" }))

        en_lamington = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Name.Translation.changeset(%Bonbon.Model.Cuisine.Name.Translation{}, %{ translate_id: 2, locale_id: en.id, term: "lamington" }))
        fr_lamington = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Name.Translation.changeset(%Bonbon.Model.Cuisine.Name.Translation{}, %{ translate_id: 2, locale_id: fr.id, term: "lamington" }))

        cuisine_pasta = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.changeset(%Bonbon.Model.Cuisine{}, %{ name: en_pasta.translate_id, region_id: region_europe.id }))
        cuisine_lamington = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.changeset(%Bonbon.Model.Cuisine{}, %{ name: en_lamington.translate_id, region_id: region_brisbane.id }))

        db = %{
            en: %{
                cuisine: %{
                    pasta: %{ "id" => to_string(cuisine_pasta.id), "name" => en_pasta.term, "region" => %{ "id" => to_string(region_europe.id), "continent" => en_continent_europe.term, "subregion" => nil, "country" => nil, "province" => nil } },
                    lamington: %{ "id" => to_string(cuisine_lamington.id), "name" => en_lamington.term, "region" => %{ "id" => to_string(region_brisbane.id), "continent" => en_continent_oceania.term, "subregion" => en_subregion_australasia.term, "country" => en_country_australia.term, "province" => en_province_brisbane.term } }
                }
            },
            fr: %{
                cuisine: %{
                    pasta: %{ "id" => to_string(cuisine_pasta.id), "name" => fr_pasta.term, "region" => %{ "id" => to_string(region_europe.id), "continent" => fr_continent_europe.term, "subregion" => nil, "country" => nil, "province" => nil } },
                    lamington: %{ "id" => to_string(cuisine_lamington.id), "name" => fr_lamington.term, "region" => %{ "id" => to_string(region_brisbane.id), "continent" => fr_continent_oceania.term, "subregion" => fr_subregion_australasia.term, "country" => fr_country_australia.term, "province" => fr_province_brisbane.term } }
                }
            }
        }

        { :ok, %{ conn: conn, db: db } }
    end

    #cuisine
    @root :cuisine
    @fields [:id, :name, region: [:id, :continent, :subregion, :country, :province]]

    @tag locale: "en"
    test "get cuisine without id", %{ conn: conn } do
        assert nil != query_error(conn, @root, @fields, [], :bad_request) #todo: possibly just check that an error was returned
    end

    #cuisine(id:)
    test_localisable_query("get cuisine with invalid id", nil, id: 0)

    test_localisable_query("get cuisine with id", &(&2[&1].cuisine.lamington), id: &(&1.en.cuisine.lamington["id"]))

    @tag locale: "en"
    test "get cuisine with non-integer id", %{ conn: conn } do
        assert _ = query_error(conn, id: "test") #todo: change to custom formatted message
    end

    #regions
    @root :cuisines

    test_localisable_query("list all cuisines", &([&2[&1].cuisine.pasta, &2[&1].cuisine.lamington]))

    test_localisable_query("list first cuisine", &([&2[&1].cuisine.pasta]), limit: 1)

    test_localisable_query("list second cuisine", &([&2[&1].cuisine.lamington]), limit: 1, offset: 1)

    @tag locale: "en"
    test "list cuisines with negative limit", %{ conn: conn } do
        assert "LIMIT must not be negative" == query_error(conn, limit: -1) #todo: change to custom formatted message
    end

    @tag locale: "en"
    test "list cuisines with negative offset", %{ conn: conn } do
        assert "OFFSET must not be negative" == query_error(conn, offset: -1) #todo: change to custom formatted message
    end

    @tag locale: "en"
    test "list cuisines with non-integer limit", %{ conn: conn } do
        assert nil != query_error(conn, @root, @fields, [limit: "test"], :bad_request) #todo: possibly just check that an error was returned
    end

    @tag locale: "en"
    test "list cuisines with non-integer offset", %{ conn: conn } do
        assert nil != query_error(conn, @root, @fields, [offset: "test"], :bad_request) #todo: possibly just check that an error was returned
    end

    #cuisines(find:)
    test_localisable_query("find 'océa' in cuisines", fn
        :en, _ -> []
        :fr, db -> [db.fr.cuisine.lamington]
    end, find: "océa")

    test_localisable_query("find 'lam' in cuisines", &([&2[&1].cuisine.lamington]), find: "lam")

    test_localisable_query("find 'au' in cuisines", &([&2[&1].cuisine.lamington]), find: "au")

    test_localisable_query("find 'br' in cuisines", &([&2[&1].cuisine.lamington]), find: "br")

    test_localisable_query("find 'zz' in cuisines", [], find: "zz")

    #cuisines(region: { continent: })
    test_localisable_query("find continent 'océa' in cuisines", fn
        :en, _ -> []
        :fr, db -> [db.fr.cuisine.lamington]
    end, region: [continent: "océa"])

    test_localisable_query("find continent 'lam' in cuisines", [], region: [continent: "lam"])

    test_localisable_query("find continent 'e' in cuisines", &([&2[&1].cuisine.pasta]), region: [continent: "e"])

    test_localisable_query("find continent 'au' in cuisines", [], region: [continent: "au"])

    test_localisable_query("find continent 'zz' in cuisines", [], region: [continent: "zz"])

    #cuisines(region: { subregion: })
    test_localisable_query("find subregion 'océa' in cuisines", [], region: [subregion: "océa"])

    test_localisable_query("find subregion 'lam' in cuisines", [], region: [subregion: "lam"])

    test_localisable_query("find subregion 'e' in cuisines", [], region: [subregion: "e"])

    test_localisable_query("find subregion 'au' in cuisines", &([&2[&1].cuisine.lamington]), region: [subregion: "au"])

    test_localisable_query("find subregion 'zz' in cuisines", [], region: [subregion: "zz"])

    # #cuisines(region: { country: })
    test_localisable_query("find country 'océa' in cuisines", [], region: [country: "océa"])

    test_localisable_query("find country 'lam' in cuisines", [], region: [country: "lam"])

    test_localisable_query("find country 'e' in cuisines", [], region: [country: "e"])

    test_localisable_query("find country 'au' in cuisines", &([&2[&1].cuisine.lamington]), region: [country: "au"])

    test_localisable_query("find country 'zz' in cuisines", [], region: [country: "zz"])

    #cuisines(region: { province: })
    test_localisable_query("find province 'br' in cuisines",  &([&2[&1].cuisine.lamington]), region: [province: "br"])

    test_localisable_query("find province 'lam' in cuisines", [], region: [province: "lam"])

    test_localisable_query("find province 'e' in cuisines", [], region: [province: "e"])

    test_localisable_query("find province 'au' in cuisines", [], region: [province: "au"])

    test_localisable_query("find province 'zz' in cuisines", [], region: [province: "zz"])

    #cuisines(region: { id: })
    test_localisable_query("find region id in cuisines",  &([&2[&1].cuisine.lamington]), region: [id: &(&1.en.cuisine.lamington["region"]["id"])])

    test_localisable_query("find invalid region id in cuisines", [], region: [id: 0])

    @tag locale: "en"
    test "find non-integer region id in cuisines", %{ conn: conn } do
        assert _ = query_error(conn, region: [id: "test"]) #todo: change to custom formatted message
    end

    #cuisines(region: { id:, continent:, subregion:, country:, province: }, find:)
    test_localisable_query("find 'p' continent 'oc', subregion 'au', country 'au', province 'br' with id in cuisines", [], find: "p", region: [id: &(&1.en.cuisine.lamington["region"]["id"]), continent: "oc", subregion: "au", country: "au", province: "br"])

    test_localisable_query("find 'l' continent 'oc', subregion 'au', country 'au', province 'br' with id in cuisines", &([&2[&1].cuisine.lamington]), find: "l", region: [id: &(&1.en.cuisine.lamington["region"]["id"]), continent: "oc", subregion: "au", country: "au", province: "br"])

    test_localisable_query("find 'l' continent 'océ', subregion 'au', country 'au', province 'br' with id in cuisines", fn
        :en, _ -> []
        :fr, db -> [db.fr.cuisine.lamington]
    end, find: "l", region: [id: &(&1.en.cuisine.lamington["region"]["id"]), continent: "océ", subregion: "au", country: "au", province: "br"])
end
