defmodule Bonbon.API.DietTest do
    use Bonbon.APICase

    setup %{ conn: conn } do
        en = Bonbon.Repo.insert!(%Bonbon.Model.Locale{ language: "en" })
        fr = Bonbon.Repo.insert!(%Bonbon.Model.Locale{ language: "fr" })
        en_vegan = Bonbon.Repo.insert!(%Bonbon.Model.Diet.Name.Translation{ translate_id: 1, locale_id: en.id, term: "vegan" })
        fr_vegan = Bonbon.Repo.insert!(%Bonbon.Model.Diet.Name.Translation{ translate_id: 1, locale_id: fr.id, term: "végétalien" })
        en_vegetarian = Bonbon.Repo.insert!(%Bonbon.Model.Diet.Name.Translation{ translate_id: 2, locale_id: en.id, term: "vegetarian" })
        fr_vegetarian = Bonbon.Repo.insert!(%Bonbon.Model.Diet.Name.Translation{ translate_id: 2, locale_id: fr.id, term: "végétarien" })

        diet_vegan = Bonbon.Repo.insert!(%Bonbon.Model.Diet{ name: en_vegan.translate_id })
        diet_vegetarian = Bonbon.Repo.insert!(%Bonbon.Model.Diet{ name: en_vegetarian.translate_id })

        db = %{
            en: %{
                diet: %{
                    vegan: %{ "id" => to_string(diet_vegan.id), "name" => en_vegan.term },
                    vegetarian: %{ "id" => to_string(diet_vegetarian.id), "name" => en_vegetarian.term }
                }
            },
            fr: %{
                diet: %{
                    vegan: %{ "id" => to_string(diet_vegan.id), "name" => fr_vegan.term },
                    vegetarian: %{ "id" => to_string(diet_vegetarian.id), "name" => fr_vegetarian.term }
                }
            }
        }

        { :ok, %{ conn: conn, db: db } }
    end

    #diet
    @root :diet
    @fields [:id, :name]

    @tag locale: "en"
    test "get diet without id", %{ conn: conn } do
        assert "1 required argument (`id') not provided" == query_error(conn) #todo: possibly just check that an error was returned
    end

    #diet(id:)
    test_localisable_query("get diet with invalid id", nil, id: 0)

    test_localisable_query("get diet with id", &(&2[&1].diet.vegetarian), id: &(&1.en.diet.vegetarian["id"]))

    @tag locale: "en"
    test "get diet with non-integer id", %{ conn: conn } do
        assert _ = query_error(conn, id: "test") #todo: change to custom formatted message
    end

    #diets
    @root :diets

    test_localisable_query("list all diets", &(Map.values(&2[&1].diet)))

    test_localisable_query("list first diet", &([&2[&1].diet.vegan]), limit: 1)

    test_localisable_query("list second diet", &([&2[&1].diet.vegetarian]), limit: 1, offset: 1)

    @tag locale: "en"
    test "list diets with negative limit", %{ conn: conn } do
        assert "LIMIT must not be negative" == query_error(conn, limit: -1) #todo: change to custom formatted message
    end

    @tag locale: "en"
    test "list diets with negative offset", %{ conn: conn } do
        assert "OFFSET must not be negative" == query_error(conn, offset: -1) #todo: change to custom formatted message
    end

    @tag locale: "en"
    test "list diets with non-integer limit", %{ conn: conn } do
        assert "1 badly formed argument (`limit') provided" == query_error(conn, limit: "test") #todo: possibly just check that an error was returned
    end

    @tag locale: "en"
    test "list diets with non-integer offset", %{ conn: conn } do
        assert "1 badly formed argument (`offset') provided" == query_error(conn, offset: "test") #todo: possibly just check that an error was returned
    end

    #diets(name:)
    test_localisable_query("find name 'vega' in diets", fn
        :en, db -> [db.en.diet.vegan]
        :fr, _ -> []
    end, name: "vega")

    test_localisable_query("find name 'végé' in diets", fn
        :en, _ -> []
        :fr, db -> Map.values(db.fr.diet)
    end, name: "végé")

    test_localisable_query("find name 'v' in diets", &(Map.values(&2[&1].diet)), name: "v")

    test_localisable_query("find name 'zz' in diets", [], name: "zz")
end
