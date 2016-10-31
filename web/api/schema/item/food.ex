defmodule Bonbon.API.Schema.Item.Food do
    use Absinthe.Schema
    use Translecto.Query
    import_types Bonbon.API.Schema.Cuisine
    import_types Bonbon.API.Schema.Diet
    import_types Bonbon.API.Schema.Ingredient
    @moduledoc false

    @desc "Some food"
    object :food do
        field :id, :id, description: "The id of the food"
        field :name, :string, description: "The name of the food"
        field :description, :string, description: "The description of the food"
        field :cuisine, :cuisine, description: "The type of cuisine the food is"
        field :diets, list_of(:diet), description: "The diets that are allowed to consume this food"
        field :ingredients, list_of(:ingredient), description: "The ingredients in the food" #todo: support addons later
        field :prep_time, :integer, description: "The preparation time of the food"
        field :available, :boolean, description: "Whether the food is available or not"
        field :calories, :integer, description: "The caloric amount of the food"
        field :price, :string, description: "The price of the food"
        field :currency, :string, description: "The currency the price is in"
        field :image, :string, description: "The image source for the food"
    end

    def get(%{ id: id, locale: locale }, _) do
        locale = Bonbon.Model.Locale.to_locale_id!(locale)
        query = from food in Bonbon.Model.Item.Food,
            where: food.id == ^id,
            locale: ^locale,
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
                price: food.price,
                currency: food.currency,
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
            food ->
                diets = Bonbon.Repo.all(from diets in Bonbon.Model.Item.Food.DietList,
                    where: diets.food_id == ^food.id,
                    locale: ^locale,
                    join: diet in Bonbon.Model.Diet, on: diet.id == diets.diet_id,
                    translate: name in diet.name,
                    select: %{
                        id: diet.id,
                        name: name.term
                    }
                )

                ingredients = Bonbon.Repo.all(from ingredients in Bonbon.Model.Item.Food.IngredientList,
                    where: ingredients.food_id == ^food.id,
                    locale: ^locale,
                    join: ingredient in Bonbon.Model.Ingredient, on: ingredient.id == ingredients.ingredient_id,
                    translate: name in ingredient.name,
                    translate: type in ingredient.type,
                    select: %{
                        id: ingredient.id,
                        name: name.term,
                        type: type.term
                    }
                )

                { :ok, Map.merge(food, %{ diets: diets, ingredients: ingredients }) }
        end
    end
end
