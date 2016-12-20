defmodule Bonbon.API.Item.FoodTest do
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

        en_vegan = Bonbon.Repo.insert!(%Bonbon.Model.Diet.Name.Translation{ translate_id: 1, locale_id: en.id, term: "vegan" })
        fr_vegan = Bonbon.Repo.insert!(%Bonbon.Model.Diet.Name.Translation{ translate_id: 1, locale_id: fr.id, term: "végétalien" })
        en_vegetarian = Bonbon.Repo.insert!(%Bonbon.Model.Diet.Name.Translation{ translate_id: 2, locale_id: en.id, term: "vegetarian" })
        fr_vegetarian = Bonbon.Repo.insert!(%Bonbon.Model.Diet.Name.Translation{ translate_id: 2, locale_id: fr.id, term: "végétarien" })

        diet_vegan = Bonbon.Repo.insert!(%Bonbon.Model.Diet{ name: en_vegan.translate_id })
        diet_vegetarian = Bonbon.Repo.insert!(%Bonbon.Model.Diet{ name: en_vegetarian.translate_id })

        en_spaghetti_napoletana_content = Bonbon.Repo.insert!(Bonbon.Model.Item.Food.Content.Translation.changeset(%Bonbon.Model.Item.Food.Content.Translation{}, %{ translate_id: 1, locale_id: en.id, name: "Spaghetti Napoletana", description: "Spaghetti in napoletana sauce" }))
        fr_spaghetti_napoletana_content = Bonbon.Repo.insert!(Bonbon.Model.Item.Food.Content.Translation.changeset(%Bonbon.Model.Item.Food.Content.Translation{}, %{ translate_id: 1, locale_id: fr.id, name: "Spaghetti Napolitaine", description: "Spaghetti en sauce napolitaine" }))

        en_lamington_content = Bonbon.Repo.insert!(Bonbon.Model.Item.Food.Content.Translation.changeset(%Bonbon.Model.Item.Food.Content.Translation{}, %{ translate_id: 2, locale_id: en.id, name: "Lamington", description: "A lamington" }))
        fr_lamington_content = Bonbon.Repo.insert!(Bonbon.Model.Item.Food.Content.Translation.changeset(%Bonbon.Model.Item.Food.Content.Translation{}, %{ translate_id: 2, locale_id: fr.id, name: "Lamington", description: "Un lamington" }))

        en_sauce = Bonbon.Repo.insert!(%Bonbon.Model.Ingredient.Type.Translation{ translate_id: 1, locale_id: en.id, term: "sauce" })
        fr_sauce = Bonbon.Repo.insert!(%Bonbon.Model.Ingredient.Type.Translation{ translate_id: 1, locale_id: fr.id, term: "sauce" })
        en_pasta = Bonbon.Repo.insert!(%Bonbon.Model.Ingredient.Type.Translation{ translate_id: 2, locale_id: en.id, term: "pasta" })
        fr_pasta = Bonbon.Repo.insert!(%Bonbon.Model.Ingredient.Type.Translation{ translate_id: 2, locale_id: fr.id, term: "pâtes" })
        en_napoletana_sauce = Bonbon.Repo.insert!(%Bonbon.Model.Ingredient.Name.Translation{ translate_id: 1, locale_id: en.id, term: "napoletana sauce" })
        fr_napoletana_sauce = Bonbon.Repo.insert!(%Bonbon.Model.Ingredient.Name.Translation{ translate_id: 1, locale_id: fr.id, term: "sauce napolitaine" })
        en_spaghetti = Bonbon.Repo.insert!(%Bonbon.Model.Ingredient.Name.Translation{ translate_id: 2, locale_id: en.id, term: "spaghetti" })
        fr_spaghetti = Bonbon.Repo.insert!(%Bonbon.Model.Ingredient.Name.Translation{ translate_id: 2, locale_id: fr.id, term: "spaghetti" })

        en_fruit = Bonbon.Repo.insert!(%Bonbon.Model.Ingredient.Type.Translation{ translate_id: 3, locale_id: en.id, term: "fruit" })
        fr_fruit = Bonbon.Repo.insert!(%Bonbon.Model.Ingredient.Type.Translation{ translate_id: 3, locale_id: fr.id, term: "fruit" })
        en_coconut = Bonbon.Repo.insert!(%Bonbon.Model.Ingredient.Name.Translation{ translate_id: 3, locale_id: en.id, term: "coconut" })
        fr_coconut = Bonbon.Repo.insert!(%Bonbon.Model.Ingredient.Name.Translation{ translate_id: 3, locale_id: fr.id, term: "noix de coco" })

        ingredient_napoletana_sauce = Bonbon.Repo.insert!(%Bonbon.Model.Ingredient{ type: en_sauce.translate_id, name: en_napoletana_sauce.translate_id })
        ingredient_spaghetti = Bonbon.Repo.insert!(%Bonbon.Model.Ingredient{ type: en_pasta.translate_id, name: en_spaghetti.translate_id })
        ingredient_coconut = Bonbon.Repo.insert!(%Bonbon.Model.Ingredient{ type: en_fruit.translate_id, name: en_coconut.translate_id })

        food_spaghetti_napoletana = Bonbon.Repo.insert!(Bonbon.Model.Item.Food.changeset(%Bonbon.Model.Item.Food{}, %{ content: en_spaghetti_napoletana_content.translate_id, cuisine_id: cuisine_pasta.id, available: true, price: Decimal.new(10), currency: "AUD", image: "pasta.jpg" }))
        food_lamington = Bonbon.Repo.insert!(Bonbon.Model.Item.Food.changeset(%Bonbon.Model.Item.Food{}, %{ content: en_lamington_content.translate_id, cuisine_id: cuisine_lamington.id, available: true, price: Decimal.new(4), currency: "AUD", image: "lamington.jpg" }))

        Bonbon.Repo.insert!(Bonbon.Model.Item.Food.IngredientList.changeset(%Bonbon.Model.Item.Food.IngredientList{}, %{ food_id: food_spaghetti_napoletana.id, ingredient_id: ingredient_napoletana_sauce.id }))
        Bonbon.Repo.insert!(Bonbon.Model.Item.Food.IngredientList.changeset(%Bonbon.Model.Item.Food.IngredientList{}, %{ food_id: food_spaghetti_napoletana.id, ingredient_id: ingredient_spaghetti.id }))
        Bonbon.Repo.insert!(Bonbon.Model.Item.Food.IngredientList.changeset(%Bonbon.Model.Item.Food.IngredientList{}, %{ food_id: food_lamington.id, ingredient_id: ingredient_coconut.id }))

        Bonbon.Repo.insert!(Bonbon.Model.Item.Food.DietList.changeset(%Bonbon.Model.Item.Food.DietList{}, %{ food_id: food_spaghetti_napoletana.id, diet_id: diet_vegan.id }))
        Bonbon.Repo.insert!(Bonbon.Model.Item.Food.DietList.changeset(%Bonbon.Model.Item.Food.DietList{}, %{ food_id: food_spaghetti_napoletana.id, diet_id: diet_vegetarian.id }))

        db = %{
            en: %{
                food: %{
                    spaghetti_napoletana: %{
                        "id" => to_string(food_spaghetti_napoletana.id),
                        "name" => en_spaghetti_napoletana_content.name,
                        "description" => en_spaghetti_napoletana_content.description,
                        "cuisine" => %{ "id" => to_string(cuisine_pasta.id), "name" => en_pasta.term, "region" => %{ "id" => to_string(region_europe.id), "continent" => en_continent_europe.term, "subregion" => nil, "country" => nil, "province" => nil } },
                        "diets" => [%{ "id" => to_string(diet_vegan.id), "name" => en_vegan.term }, %{ "id" => to_string(diet_vegetarian.id), "name" => en_vegetarian.term }],
                        "ingredients" => [%{ "id" => to_string(ingredient_napoletana_sauce.id), "type" => en_sauce.term, "name" => en_napoletana_sauce.term }, %{ "id" => to_string(ingredient_spaghetti.id), "type" => en_pasta.term, "name" => en_spaghetti.term }],
                        "prep_time" => nil,
                        "available" => true,
                        "calories" => nil,
                        "price" => %{ "amount" => "10", "currency" => "AUD", "presentable" => "$10.00" },
                        "image" => "pasta.jpg"
                    },
                    lamington: %{
                        "id" => to_string(food_lamington.id),
                        "name" => en_lamington_content.name,
                        "description" => en_lamington_content.description,
                        "cuisine" => %{ "id" => to_string(cuisine_lamington.id), "name" => en_lamington.term, "region" => %{ "id" => to_string(region_brisbane.id), "continent" => en_continent_oceania.term, "subregion" => en_subregion_australasia.term, "country" => en_country_australia.term, "province" => en_province_brisbane.term } },
                        "diets" => [],
                        "ingredients" => [%{ "id" => to_string(ingredient_coconut.id), "type" => en_fruit.term, "name" => en_coconut.term }],
                        "prep_time" => nil,
                        "available" => true,
                        "calories" => nil,
                        "price" => %{ "amount" => "4", "currency" => "AUD", "presentable" => "$4.00" },
                        "image" => "lamington.jpg"
                    }
                }
            },
            fr: %{
                food: %{
                    spaghetti_napoletana: %{
                        "id" => to_string(food_spaghetti_napoletana.id),
                        "name" => fr_spaghetti_napoletana_content.name,
                        "description" => fr_spaghetti_napoletana_content.description,
                        "cuisine" => %{ "id" => to_string(cuisine_pasta.id), "name" => fr_pasta.term, "region" => %{ "id" => to_string(region_europe.id), "continent" => fr_continent_europe.term, "subregion" => nil, "country" => nil, "province" => nil } },
                        "diets" => [%{ "id" => to_string(diet_vegan.id), "name" => fr_vegan.term }, %{ "id" => to_string(diet_vegetarian.id), "name" => fr_vegetarian.term }],
                        "ingredients" => [%{ "id" => to_string(ingredient_napoletana_sauce.id), "type" => fr_sauce.term, "name" => fr_napoletana_sauce.term }, %{ "id" => to_string(ingredient_spaghetti.id), "type" => fr_pasta.term, "name" => fr_spaghetti.term }],
                        "prep_time" => nil,
                        "available" => true,
                        "calories" => nil,
                        "price" => %{ "amount" => "10", "currency" => "AUD", "presentable" => "$10.00" },
                        "image" => "pasta.jpg"
                    },
                    lamington: %{
                        "id" => to_string(food_lamington.id),
                        "name" => fr_lamington_content.name,
                        "description" => fr_lamington_content.description,
                        "cuisine" => %{ "id" => to_string(cuisine_lamington.id), "name" => fr_lamington.term, "region" => %{ "id" => to_string(region_brisbane.id), "continent" => fr_continent_oceania.term, "subregion" => fr_subregion_australasia.term, "country" => fr_country_australia.term, "province" => fr_province_brisbane.term } },
                        "diets" => [],
                        "ingredients" => [%{ "id" => to_string(ingredient_coconut.id), "type" => fr_fruit.term, "name" => fr_coconut.term }],
                        "prep_time" => nil,
                        "available" => true,
                        "calories" => nil,
                        "price" => %{ "amount" => "4", "currency" => "AUD", "presentable" => "$4.00" },
                        "image" => "lamington.jpg"
                    }
                }
            }
        }

        { :ok, %{ conn: conn, db: db } }
    end

    #region
    @root :food
    @fields [
        :id,
        :name,
        :description,
        :prep_time,
        :available,
        :calories,
        :image,
        price: [:amount, :currency, :presentable],
        cuisine: [:id, :name, region: [:id, :continent, :subregion, :country, :province]],
        diets: [:id, :name],
        ingredients: [:id, :type, :name]
    ]

    @tag locale: "en"
    test "get food without id", %{ conn: conn } do
        assert nil != query_error(conn, @root, @fields, [], :bad_request) #todo: possibly just check that an error was returned
    end

    #food(id:)
    test_localisable_query("get food with invalid id", nil, id: 0)

    test_localisable_query("get food with id", &(&2[&1].food.spaghetti_napoletana), id: &(&1.en.food.spaghetti_napoletana["id"]))

    @tag locale: "en"
    test "get food with non-integer id", %{ conn: conn } do
        assert _ = query_error(conn, id: "test") #todo: change to custom formatted message
    end

    #foods
    @root :foods

    test_localisable_query("list all foods", &([&2[&1].food.lamington, &2[&1].food.spaghetti_napoletana]))

    test_localisable_query("list first food", &([&2[&1].food.spaghetti_napoletana]), limit: 1)

    test_localisable_query("list second food", &([&2[&1].food.lamington]), limit: 1, offset: 1)

    @tag locale: "en"
    test "list foods with negative limit", %{ conn: conn } do
        assert "LIMIT must not be negative" == query_error(conn, limit: -1) #todo: change to custom formatted message
    end

    @tag locale: "en"
    test "list foods with negative offset", %{ conn: conn } do
        assert "OFFSET must not be negative" == query_error(conn, offset: -1) #todo: change to custom formatted message
    end

    @tag locale: "en"
    test "list foods with non-integer limit", %{ conn: conn } do
        assert nil != query_error(conn, @root, @fields, [limit: "test"], :bad_request) #todo: possibly just check that an error was returned
    end

    @tag locale: "en"
    test "list foods with non-integer offset", %{ conn: conn } do
        assert nil != query_error(conn, @root, @fields, [offset: "test"], :bad_request) #todo: possibly just check that an error was returned
    end

    #foods(name:)
    test_localisable_query("find name 'spaghetti napoletana' in foods", fn
        :en, db -> [db.en.food.spaghetti_napoletana]
        :fr, _ -> []
    end, name: "spaghetti napoletana")

    test_localisable_query("find name 'spaghetti napolitaine' in foods", fn
        :en, _ -> []
        :fr, db -> [db.fr.food.spaghetti_napoletana]
    end, name: "spaghetti napolitaine")

    test_localisable_query("find name 'lam' in foods", &([&2[&1].food.lamington]), name: "lam")

    test_localisable_query("find name 'spa' in foods", &([&2[&1].food.spaghetti_napoletana]), name: "spa")

    test_localisable_query("find name 'zz' in foods", [], name: "zz")

    #foods(prices:)
    test_localisable_query("find prices '4 - 10' in foods", &([&2[&1].food.lamington, &2[&1].food.spaghetti_napoletana]), prices: [min: "4", max: "10", currency: "AUD"])

    test_localisable_query("find prices '4 - 9' in foods", &([&2[&1].food.lamington]), prices: [min: "4", max: "9", currency: "AUD"])

    #will fail until updated to Ecto 2.1 so we can use or_where
    test_localisable_query("find prices '4 - 9' or '10 - 10' in foods", &([&2[&1].food.lamington, &2[&1].food.spaghetti_napoletana]), prices: [[min: "4", max: "9", currency: "AUD"], [min: "10", max: "10", currency: "AUD"]])

    test_localisable_query("find prices '0 - 3' in foods", [], prices: [min: "0", max: "3", currency: "AUD"])

    test_localisable_query("find prices '4 - 10 USD' in foods", [], prices: [min: "4", max: "10", currency: "USD"])

    #foods(diets: { name: })
    test_localisable_query("find diets by name 'veg' in foods", fn
        :en, db -> [db.en.food.spaghetti_napoletana]
        :fr, _ -> []
    end, diets: [name: "veg"])

    test_localisable_query("find diets by name 'vég' in foods", fn
        :en, _ -> []
        :fr, db -> [db.fr.food.spaghetti_napoletana]
    end, diets: [name: "vég"])

    test_localisable_query("find diets by names 'veg' or 'vég' in foods", &([&2[&1].food.spaghetti_napoletana]), diets: [[name: "veg"], [name: "vég"]])

    test_localisable_query("find diets by names 'vegan' or 'zzz' in foods", fn
        :en, db -> [db.en.food.spaghetti_napoletana]
        :fr, _ -> []
    end, diets: [[name: "vegan"], [name: "zzz"]])

    test_localisable_query("find diets by name 'zz' in foods", [], diets: [name: "zz"])

    #foods(diets: { id: })
    test_localisable_query("find diets by id in foods", &([&2[&1].food.spaghetti_napoletana]), diets: [id: &(List.first(&1.en.food.spaghetti_napoletana["diets"])["id"])])

    test_localisable_query("find diets by invalid id in foods", [], diets: [id: "0"])

    test_localisable_query("find diets by id's in foods", &([&2[&1].food.spaghetti_napoletana]), diets: [[id: &(List.first(&1.en.food.spaghetti_napoletana["diets"])["id"])], [id: &(List.last(&1.en.food.spaghetti_napoletana["diets"])["id"])]])

    test_localisable_query("find diets by valid and invalid id's in foods", &([&2[&1].food.spaghetti_napoletana]), diets: [[id: "0"], [id: &(List.last(&1.en.food.spaghetti_napoletana["diets"])["id"])]])

    @tag locale: "en"
    test "find non-integer diet id in foods", %{ conn: conn } do
        assert _ = query_error(conn, diets: [id: "test"]) #todo: change to custom formatted message
    end

    #foods(ingredients: { name: })
    test_localisable_query("find ingredients by name 'napoletana sauce' in foods", fn
        :en, db -> [db.en.food.spaghetti_napoletana]
        :fr, _ -> []
    end, ingredients: [name: "napoletana sauce"])

    test_localisable_query("find ingredients by name 'sauce napolitaine' in foods", fn
        :en, _ -> []
        :fr, db -> [db.fr.food.spaghetti_napoletana]
    end, ingredients: [name: "sauce napolitaine"])

    test_localisable_query("find ingredients by names 'coconut' or 'sauce napolitaine' in foods", fn
        :en, db -> [db.en.food.lamington]
        :fr, db -> [db.fr.food.spaghetti_napoletana]
    end, ingredients: [[name: "coconut"], [name: "sauce napolitaine"]])

    test_localisable_query("find ingredients by names 'spaghetti' or 'zzz' in foods", &([&2[&1].food.spaghetti_napoletana]), ingredients: [[name: "spaghetti"], [name: "zzz"]])

    test_localisable_query("find ingredients by name 'zz' in foods", [], ingredients: [name: "zz"])

    #foods(ingredients: { type: })
    test_localisable_query("find ingredients by type 'pasta' in foods", fn
        :en, db -> [db.en.food.spaghetti_napoletana]
        :fr, _ -> []
    end, ingredients: [type: "pasta"])

    test_localisable_query("find ingredients by type 'pâtes' in foods", fn
        :en, _ -> []
        :fr, db -> [db.fr.food.spaghetti_napoletana]
    end, ingredients: [type: "pâtes"])

    test_localisable_query("find ingredients by types 'fruit' or 'pâtes' in foods", fn
        :en, db -> [db.en.food.lamington]
        :fr, db -> [db.fr.food.lamington, db.fr.food.spaghetti_napoletana]
    end, ingredients: [[type: "fruit"], [type: "pâtes"]])

    test_localisable_query("find ingredients by types 'sauce' or 'zzz' in foods", &([&2[&1].food.spaghetti_napoletana]), ingredients: [[type: "sauce"], [type: "zzz"]])

    test_localisable_query("find ingredients by type 'zz' in foods", [], ingredients: [type: "zz"])

    #foods(ingredients: { name:, type: })
    test_localisable_query("find ingredients by name 'napoletana sauce' and type 'sauce' in foods", &([&2[&1].food.spaghetti_napoletana]), ingredients: [name: "napoletana sauce", type: "sauce"])

    test_localisable_query("find ingredients by name 'sauce napolitaine' and type 'pâtes' in foods", fn
        :en, _ -> []
        :fr, db -> [db.fr.food.spaghetti_napoletana]
    end, ingredients: [name: "sauce napolitaine", type: "pâtes"])

    test_localisable_query("find ingredients by name 'sauce napolitaine' and type 'pasta' in foods", &([&2[&1].food.spaghetti_napoletana]), ingredients: [name: "sauce napolitaine", type: "pasta"])

    test_localisable_query("find ingredients by names 'sauce napolitaine' or types 'pâtes' in foods", fn
        :en, _ -> []
        :fr, db -> [db.fr.food.spaghetti_napoletana]
    end, ingredients: [[name: "sauce napolitaine"], [type: "pâtes"]])

    test_localisable_query("find ingredients by name 'zz' and type 'zz' in foods", [], ingredients: [name: "zz", type: "zz"])

    #foods(ingredients: { id: })
    test_localisable_query("find ingredients by id in foods", &([&2[&1].food.spaghetti_napoletana]), ingredients: [id: &(List.first(&1.en.food.spaghetti_napoletana["ingredients"])["id"])])

    test_localisable_query("find ingredients by invalid id in foods", [], ingredients: [id: "0"])

    test_localisable_query("find ingredients by id's in foods", &([&2[&1].food.spaghetti_napoletana]), ingredients: [[id: &(List.first(&1.en.food.spaghetti_napoletana["ingredients"])["id"])], [id: &(List.last(&1.en.food.spaghetti_napoletana["ingredients"])["id"])]])

    test_localisable_query("find ingredients by valid and invalid id's in foods", &([&2[&1].food.spaghetti_napoletana]), ingredients: [[id: "0"], [id: &(List.last(&1.en.food.spaghetti_napoletana["ingredients"])["id"])]])

    @tag locale: "en"
    test "find non-integer ingredient id in foods", %{ conn: conn } do
        assert _ = query_error(conn, ingredients: [id: "test"]) #todo: change to custom formatted message
    end
end
