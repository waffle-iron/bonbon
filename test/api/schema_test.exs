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

    @tag locale: "en"
    test "get ingredient without id", %{ conn: conn, db: db } do
        assert "1 required argument (`id') not provided" == query_error(conn, :ingredient, [:id, :name, :type])
    end

    test_localisable_query("get ingredient with invalid id", nil, :ingredient, [:id, :name, :type], id: 0)

    test_localisable_query("get ingredient with id", &(&2[&1].ingredient.lemon), :ingredient, [:id, :name, :type], id: &(&1.en.ingredient.lemon["id"]))

    test_localisable_query("list all ingredients", &(Map.values(&2[&1].ingredient)), :ingredients, [:id, :name, :type])

    test_localisable_query("find 'ap' in ingredients", fn
        :en, db -> [db.en.ingredient.apple]
        :fr, _ -> []
    end, :ingredients, [:id, :name, :type], find: "ap")

    test_localisable_query("find 'fr' in ingredients", &(Map.values(&2[&1].ingredient)), :ingredients, [:id, :name, :type], find: "fr")

    test_localisable_query("find 'zz' in ingredients", fn _, _ -> [] end, :ingredients, [:id, :name, :type], find: "zz")
end
