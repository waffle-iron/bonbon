defmodule Bonbon.API.Schema.Item.Food do
    use Absinthe.Schema
    use Translecto.Query
    import_types Bonbon.API.Schema.Cuisine
    import_types Bonbon.API.Schema.Diet
    import_types Bonbon.API.Schema.Allergen
    import_types Bonbon.API.Schema.Ingredient
    import_types Bonbon.API.Schema.Price
    @moduledoc false

    @desc "Some food"
    object :food do
        field :id, :id, description: "The id of the food"
        field :name, :string, description: "The name of the food"
        field :description, :string, description: "The description of the food"
        field :cuisine, :cuisine, description: "The type of cuisine the food is"
        field :diets, list_of(:diet), description: "The diets that are allowed to consume this food"
        field :allergens, list_of(:allergen), description: "The allergens this food effects"
        field :ingredients, list_of(:ingredient), description: "The ingredients in the food" #todo: support addons later
        field :prep_time, :integer, description: "The preparation time of the food"
        field :available, :boolean, description: "Whether the food is available or not"
        field :calories, :integer, description: "The caloric amount of the food"
        field :price, :price, description: "The price of the food"
        field :image, :string, description: "The image source for the food"
    end

    #todo: convert to query as this won't respect pagination
    defp filter(food, args = %{ ingredients: [] }, foods), do: filter(food, Map.delete(args, :ingredients), foods)
    defp filter(food, args = %{ ingredients: ingredients }, foods) do
        if Enum.any?(ingredients, fn ingredient ->
            Enum.any?(ingredient, fn
                { :id, id } -> Enum.any?(food.ingredients, &(&1.id == String.to_integer(id)))
                { :name, name } -> Enum.any?(food.ingredients, &String.starts_with?(&1.name, name))
                { :type, type } -> Enum.any?(food.ingredients, &String.starts_with?(&1.type, type))
            end)
        end) do
            filter(food, Map.delete(args, :ingredients), foods)
        else
            foods
        end
    end
    defp filter(food, args = %{ diets: [] }, foods), do: filter(food, Map.delete(args, :diets), foods)
    defp filter(food, args = %{ diets: diets }, foods) do
        if Enum.any?(diets, fn diet ->
            Enum.any?(diet, fn
                { :id, id } -> Enum.any?(food.diets, &(&1.id == String.to_integer(id)))
                { :name, name } -> Enum.any?(food.diets, &String.starts_with?(&1.name, name))
            end)
        end) do
            filter(food, Map.delete(args, :diets), foods)
        else
            foods
        end
    end
    defp filter(food, args = %{ allergens: allergens }, foods) do
        if Enum.any?(allergens, fn allergen ->
            Enum.any?(allergen, fn
                { :id, id } -> Enum.any?(food.allergens, &(&1.id == String.to_integer(id)))
                { :name, name } -> Enum.any?(food.allergens, &String.starts_with?(&1.name, name))
            end)
        end) do
            foods
        else
            filter(food, Map.delete(args, :allergens), foods)
        end
    end
    defp filter(food, _, foods), do: [food|foods]

    def format(food, locale) do
        diets = Bonbon.Repo.all(from diets in Bonbon.Model.Item.Food.DietList,
            where: diets.food_id == ^food.id,
            locales: ^locale,
            join: diet in Bonbon.Model.Diet, on: diet.id == diets.diet_id,
            translate: name in diet.name,
            select: %{
                id: diet.id,
                name: name.term
            }
        )

        allergens = Bonbon.Repo.all(from allergens in Bonbon.Model.Item.Food.AllergenList,
            where: allergens.food_id == ^food.id,
            locales: ^locale,
            join: allergen in Bonbon.Model.Allergen, on: allergen.id == allergens.allergen_id,
            translate: name in allergen.name,
            select: %{
                id: allergen.id,
                name: name.term
            }
        )

        ingredients = Bonbon.Repo.all(from ingredients in Bonbon.Model.Item.Food.IngredientList,
            where: ingredients.food_id == ^food.id,
            locales: ^locale,
            join: ingredient in Bonbon.Model.Ingredient, on: ingredient.id == ingredients.ingredient_id,
            translate: name in ingredient.name,
            translate: type in ingredient.type,
            select: %{
                id: ingredient.id,
                name: name.term,
                type: type.term
            }
        )

        Map.merge(food, %{
            diets: diets,
            allergens: allergens,
            ingredients: ingredients,
            price: Bonbon.API.Schema.Price.format(food.price, locale),
            cuisine: Bonbon.API.Schema.Cuisine.format(food.cuisine)
        })
    end

    def get(%{ id: id, locale: locale }, _) do
        locale = Bonbon.Model.Locale.to_locale_id_list!(locale)
        query = from food in Bonbon.Model.Item.Food,
            where: food.id == ^id,
            locales: ^locale,
            translate: content in food.content,
            join: cuisine in Bonbon.Model.Cuisine, on: cuisine.id == food.cuisine_id,
            translate: cuisine_name in cuisine.name,
            join: region in Bonbon.Model.Cuisine.Region, on: region.id == cuisine.region_id,
            translate: continent in region.continent,
            translate: subregion in region.subregion,
            translate: country in region.country,
            translate: province in region.province,
            select: %{
                id: food.id,
                name: content.name,
                description: content.description,
                prep_time: food.prep_time,
                available: food.available,
                calories: food.calories,
                price: %{
                    amount: food.price,
                    currency: food.currency
                },
                image: food.image,
                cuisine: %{
                    id: cuisine.id,
                    name: cuisine_name.term,
                    region: %{
                        id: region.id,
                        continent: continent.term,
                        subregion: subregion.term,
                        country: country.term,
                        province: province.term
                    }
                }
            }

        case Bonbon.Repo.one(query) do
            nil -> { :error, "Could not find food" }
            result -> { :ok, format(result, locale) }
        end
    end

    defp query_all(args = %{ name: name }, locale) do
        name = name <> "%"
        where(query_all(Map.delete(args, :name), locale), [f, fc], ilike(fc.name, ^name))
    end
    defp query_all(args = %{ cuisines: cuisines }, locale) do
        #todo: change to or_where when using Ecto 2.1
        Enum.reduce(cuisines, query_all(Map.delete(args, :cuisines), locale), fn
            cuisine, query ->
                Enum.reduce(cuisine, query, fn
                    { :id, id }, query -> where(query, [f, fc, c], c.id == ^id)
                    { :name, name }, query -> where(query, [f, fc, c, cn], ilike(cn.term, ^(name <> "%")))
                    { :region, region }, query ->
                        Enum.reduce(region, query, fn
                            { :id, id }, query -> where(query, [f, fc, c, cn, r, rc, rs, rn, rp], r.id == ^id)
                            { :continent, continent }, query -> where(query, [f, fc, c, cn, r, rc, rs, rn, rp], ilike(rc.term, ^(continent <> "%")))
                            { :subregion, subregion }, query -> where(query, [f, fc, c, cn, r, rc, rs, rn, rp], ilike(rs.term, ^(subregion <> "%")))
                            { :country, country }, query -> where(query, [f, fc, c, cn, r, rc, rs, rn, rp], ilike(rn.term, ^(country <> "%")))
                            { :province, province }, query -> where(query, [f, fc, c, cn, r, rc, rs, rn, rp], ilike(rp.term, ^(province <> "%")))
                        end)
                end)
        end)
    end
    defp query_all(args = %{ prices: prices }, locale) do
        #todo: change to or_where when using Ecto 2.1
        Enum.reduce(prices, query_all(Map.delete(args, :prices), locale), fn
            price, query -> where(query, [f], f.price <= ^price.max and f.price >= ^price.min and ilike(f.currency, ^price.currency))
        end)
    end
    defp query_all(%{ limit: limit, offset: offset }, locale) do
        from food in Bonbon.Model.Item.Food,
            locales: ^locale,
            translate: content in food.content,
            join: cuisine in Bonbon.Model.Cuisine, on: cuisine.id == food.cuisine_id,
            translate: cuisine_name in cuisine.name,
            join: region in Bonbon.Model.Cuisine.Region, on: region.id == cuisine.region_id,
            translate: continent in region.continent,
            translate: subregion in region.subregion,
            translate: country in region.country,
            translate: province in region.province,
            limit: ^limit,
            offset: ^offset, #todo: paginate
            select: %{
                id: food.id,
                name: content.name,
                description: content.description,
                prep_time: food.prep_time,
                available: food.available,
                calories: food.calories,
                price: %{
                    amount: food.price,
                    currency: food.currency
                },
                image: food.image,
                cuisine: %{
                    id: cuisine.id,
                    name: cuisine_name.term,
                    region: %{
                        id: region.id,
                        continent: continent.term,
                        subregion: subregion.term,
                        country: country.term,
                        province: province.term
                    }
                }
            }
    end

    def all(args, _) do
        locale = Bonbon.Model.Locale.to_locale_id_list!(args.locale)
        case Bonbon.Repo.all(query_all(args, locale)) do
            nil -> { :error, "Could not retrieve any foods" }
            result -> { :ok, Enum.reduce(result, [], &filter(format(&1, locale), args, &2)) }
        end
    end
end
