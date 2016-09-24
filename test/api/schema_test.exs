defmodule Bonbon.API.SchemaTest do
    use Bonbon.APICase

    setup %{ conn: conn } do
        en = Bonbon.Repo.insert!(%Bonbon.Model.Locale{ language: "en" })
        fr = Bonbon.Repo.insert!(%Bonbon.Model.Locale{ language: "fr" })
        en_fruit = Bonbon.Repo.insert!(%Bonbon.Model.Ingredient.Type.Translation{ translate_id: 1, locale_id: en.id, term: "fruit" })
        fr_fruit = Bonbon.Repo.insert!(%Bonbon.Model.Ingredient.Type.Translation{ translate_id: 1, locale_id: fr.id, term: "fruit" })
        en_apple = Bonbon.Repo.insert!(%Bonbon.Model.Ingredient.Name.Translation{ translate_id: 1, locale_id: en.id, term: "apple" })
        fr_apple = Bonbon.Repo.insert!(%Bonbon.Model.Ingredient.Name.Translation{ translate_id: 1, locale_id: fr.id, term: "pomme" })
        en_lemon = Bonbon.Repo.insert!(%Bonbon.Model.Ingredient.Name.Translation{ translate_id: 2, locale_id: en.id, term: "lemon" })
        fr_lemon = Bonbon.Repo.insert!(%Bonbon.Model.Ingredient.Name.Translation{ translate_id: 2, locale_id: fr.id, term: "citron" })

        ingredient_apple = Bonbon.Repo.insert!(%Bonbon.Model.Ingredient{ type: en_fruit.translate_id, name: en_apple.translate_id })
        ingredient_lemon = Bonbon.Repo.insert!(%Bonbon.Model.Ingredient{ type: en_fruit.translate_id, name: en_lemon.translate_id })

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
                ingredient: %{
                    apple: %{ "id" => to_string(ingredient_apple.id), "type" => en_fruit.term, "name" => en_apple.term },
                    lemon: %{ "id" => to_string(ingredient_lemon.id), "type" => en_fruit.term, "name" => en_lemon.term }
                },
                region: %{
                    estuaire: %{ "id" => to_string(region_estuaire.id), "continent" => en_continent.term, "subregion" => en_subregion.term, "country" => en_country.term, "province" => en_province.term },
                    gabon: %{ "id" => to_string(region_gabon.id), "continent" => en_continent.term, "subregion" => en_subregion.term, "country" => en_country.term, "province" => nil },
                    central_africa: %{ "id" => to_string(region_central_africa.id), "continent" => en_continent.term, "subregion" => en_subregion.term, "country" => nil, "province" => nil },
                    africa: %{ "id" => to_string(region_africa.id), "continent" => en_continent.term, "subregion" => nil, "country" => nil, "province" => nil }
                }
            },
            fr: %{
                ingredient: %{
                    apple: %{ "id" => to_string(ingredient_apple.id), "type" => fr_fruit.term, "name" => fr_apple.term },
                    lemon: %{ "id" => to_string(ingredient_lemon.id), "type" => fr_fruit.term, "name" => fr_lemon.term }
                },
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

    #ingredient
    @subfields [:id, :name, :type]

    @tag locale: "en"
    test "get ingredient without id", %{ conn: conn, db: db } do
        assert "1 required argument (`id') not provided" == query_error(conn, :ingredient, @subfields) #todo: possibly just check that an error was returned
    end

    #ingredient(id:)
    test_localisable_query("get ingredient with invalid id", nil, :ingredient, @subfields, id: 0)

    test_localisable_query("get ingredient with id", &(&2[&1].ingredient.lemon), :ingredient, @subfields, id: &(&1.en.ingredient.lemon["id"]))

    @tag locale: "en"
    test "get ingredient with non-integer id", %{ conn: conn, db: db } do
        assert _ = query_error(conn, :ingredient, @subfields, id: "test") #todo: change to custom formatted message
    end

    #ingredients
    test_localisable_query("list all ingredients", &(Map.values(&2[&1].ingredient)), :ingredients, @subfields)

    test_localisable_query("list first ingredient", &([&2[&1].ingredient.apple]), :ingredients, @subfields, limit: 1)

    test_localisable_query("list second ingredient", &([&2[&1].ingredient.lemon]), :ingredients, @subfields, limit: 1, offset: 1)

    @tag locale: "en"
    test "list ingredients with negative limit", %{ conn: conn, db: db } do
        assert "LIMIT must not be negative" == query_error(conn, :ingredients, @subfields, limit: -1) #todo: change to custom formatted message
    end

    @tag locale: "en"
    test "list ingredients with negative offset", %{ conn: conn, db: db } do
        assert "OFFSET must not be negative" == query_error(conn, :ingredients, @subfields, offset: -1) #todo: change to custom formatted message
    end

    @tag locale: "en"
    test "list ingredients with non-integer limit", %{ conn: conn, db: db } do
        assert "1 badly formed argument (`limit') provided" == query_error(conn, :ingredients, @subfields, limit: "test") #todo: possibly just check that an error was returned
    end

    @tag locale: "en"
    test "list ingredients with non-integer offset", %{ conn: conn, db: db } do
        assert "1 badly formed argument (`offset') provided" == query_error(conn, :ingredients, @subfields, offset: "test") #todo: possibly just check that an error was returned
    end

    #ingredients(find:)
    test_localisable_query("find 'ap' in ingredients", fn
        :en, db -> [db.en.ingredient.apple]
        :fr, _ -> []
    end, :ingredients, @subfields, find: "ap")

    test_localisable_query("find 'pomme' in ingredients", fn
        :en, _ -> []
        :fr, db -> [db.fr.ingredient.apple]
    end, :ingredients, @subfields, find: "pomme")

    test_localisable_query("find 'fr' in ingredients", &(Map.values(&2[&1].ingredient)), :ingredients, @subfields, find: "fr")

    test_localisable_query("find 'zz' in ingredients", [], :ingredients, @subfields, find: "zz")

    #ingredients(name:)
    test_localisable_query("find name 'ap' in ingredients", fn
        :en, db -> [db.en.ingredient.apple]
        :fr, _ -> []
    end, :ingredients, @subfields, name: "ap")

    test_localisable_query("find name 'pomme' in ingredients", fn
        :en, _ -> []
        :fr, db -> [db.fr.ingredient.apple]
    end, :ingredients, @subfields, name: "pomme")

    test_localisable_query("find name 'fr' in ingredients", [], :ingredients, @subfields, name: "fr")

    test_localisable_query("find name 'zz' in ingredients", [], :ingredients, @subfields, name: "zz")

    #ingredients(type:)
    test_localisable_query("find type 'ap' in ingredients", [], :ingredients, @subfields, type: "ap")

    test_localisable_query("find type 'pomme' in ingredients", [], :ingredients, @subfields, type: "pomme")

    test_localisable_query("find type 'fr' in ingredients", &(Map.values(&2[&1].ingredient)), :ingredients, @subfields, type: "fr")

    test_localisable_query("find type 'zz' in ingredients", [], :ingredients, @subfields, type: "zz")

    #ingredients(name:, type:, find:)
    test_localisable_query("find 'ci' name 'ap', type 'fr' in ingredients", [], :ingredients, @subfields, find: "ci", name: "ap", type: "fr")

    test_localisable_query("find 'ci' name 'c', type 'fr' in ingredients", fn
        :en, _ -> []
        :fr, db -> [db.fr.ingredient.lemon]
    end, :ingredients, @subfields, find: "ci", name: "c", type: "fr")

    #region
    @subfields [:id, :continent, :subregion, :country, :province]

    @tag locale: "en"
    test "get region without id", %{ conn: conn, db: db } do
        assert "1 required argument (`id') not provided" == query_error(conn, :region, @subfields) #todo: possibly just check that an error was returned
    end

    #region(id:)
    test_localisable_query("get region with invalid id", nil, :region, @subfields, id: 0)

    test_localisable_query("get region with id", &(&2[&1].region.gabon), :region, @subfields, id: &(&1.en.region.gabon["id"]))

    @tag locale: "en"
    test "get region with non-integer id", %{ conn: conn, db: db } do
        assert _ = query_error(conn, :region, @subfields, id: "test") #todo: change to custom formatted message
    end
end
