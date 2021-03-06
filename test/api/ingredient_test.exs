defmodule Bonbon.API.IngredientTest do
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

        db = %{
            en: %{
                ingredient: %{
                    apple: %{ "id" => to_string(ingredient_apple.id), "type" => en_fruit.term, "name" => en_apple.term },
                    lemon: %{ "id" => to_string(ingredient_lemon.id), "type" => en_fruit.term, "name" => en_lemon.term }
                }
            },
            fr: %{
                ingredient: %{
                    apple: %{ "id" => to_string(ingredient_apple.id), "type" => fr_fruit.term, "name" => fr_apple.term },
                    lemon: %{ "id" => to_string(ingredient_lemon.id), "type" => fr_fruit.term, "name" => fr_lemon.term }
                }
            }
        }

        { :ok, %{ conn: conn, db: db } }
    end

    #ingredient
    @root :ingredient
    @fields [:id, :name, :type]

    @tag locale: "en"
    test "get ingredient without id", %{ conn: conn } do
        assert nil != query_error(conn, @root, @fields, [], :bad_request) #todo: possibly just check that an error was returned
    end

    #ingredient(id:)
    test_localisable_query("get ingredient with invalid id", nil, id: 0)

    test_localisable_query("get ingredient with id", &(&2[&1].ingredient.lemon), id: &(&1.en.ingredient.lemon["id"]))

    @tag locale: "en"
    test "get ingredient with non-integer id", %{ conn: conn } do
        assert _ = query_error(conn, id: "test") #todo: change to custom formatted message
    end

    #ingredients
    @root :ingredients

    test_localisable_query("list all ingredients", &(Map.values(&2[&1].ingredient)))

    test_localisable_query("list first ingredient", &([&2[&1].ingredient.apple]), limit: 1)

    test_localisable_query("list second ingredient", &([&2[&1].ingredient.lemon]), limit: 1, offset: 1)

    @tag locale: "en"
    test "list ingredients with negative limit", %{ conn: conn } do
        assert "LIMIT must not be negative" == query_error(conn, limit: -1) #todo: change to custom formatted message
    end

    @tag locale: "en"
    test "list ingredients with negative offset", %{ conn: conn } do
        assert "OFFSET must not be negative" == query_error(conn, offset: -1) #todo: change to custom formatted message
    end

    @tag locale: "en"
    test "list ingredients with non-integer limit", %{ conn: conn } do
        assert nil != query_error(conn, @root, @fields, [limit: "test"], :bad_request) #todo: possibly just check that an error was returned
    end

    @tag locale: "en"
    test "list ingredients with non-integer offset", %{ conn: conn } do
        assert nil != query_error(conn, @root, @fields, [offset: "test"], :bad_request) #todo: possibly just check that an error was returned
    end

    #ingredients(find:)
    test_localisable_query("find 'ap' in ingredients", fn
        :en, db -> [db.en.ingredient.apple]
        :fr, _ -> []
    end, find: "ap")

    test_localisable_query("find 'pomme' in ingredients", fn
        :en, _ -> []
        :fr, db -> [db.fr.ingredient.apple]
    end, find: "pomme")

    test_localisable_query("find 'fr' in ingredients", &(Map.values(&2[&1].ingredient)), find: "fr")

    test_localisable_query("find 'zz' in ingredients", [], find: "zz")

    #ingredients(name:)
    test_localisable_query("find name 'ap' in ingredients", fn
        :en, db -> [db.en.ingredient.apple]
        :fr, _ -> []
    end, name: "ap")

    test_localisable_query("find name 'pomme' in ingredients", fn
        :en, _ -> []
        :fr, db -> [db.fr.ingredient.apple]
    end, name: "pomme")

    test_localisable_query("find name 'fr' in ingredients", [], name: "fr")

    test_localisable_query("find name 'zz' in ingredients", [], name: "zz")

    #ingredients(type:)
    test_localisable_query("find type 'ap' in ingredients", [], type: "ap")

    test_localisable_query("find type 'pomme' in ingredients", [], type: "pomme")

    test_localisable_query("find type 'fr' in ingredients", &(Map.values(&2[&1].ingredient)), type: "fr")

    test_localisable_query("find type 'zz' in ingredients", [], type: "zz")

    #ingredients(name:, type:, find:)
    test_localisable_query("find 'ci' name 'ap', type 'fr' in ingredients", [], find: "ci", name: "ap", type: "fr")

    test_localisable_query("find 'ci' name 'c', type 'fr' in ingredients", fn
        :en, _ -> []
        :fr, db -> [db.fr.ingredient.lemon]
    end, find: "ci", name: "c", type: "fr")
end
