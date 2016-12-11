# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Bonbon.Repo.insert!(%Bonbon.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

#todo: Make static
#rip: http://www.lingoes.net/en/translator/langcode.htm
HTTPoison.start
html = HTTPoison.get!("http://www.lingoes.net/en/translator/langcode.htm").body
[_|codes] = Floki.find(html, "tr")
codes = Enum.map(codes, fn { _, _, [{ _, _, [code] }|_] } ->
    case String.split(code, "-") do
        [language, country] -> %{ language: language, country: country }
        [language] -> %{ language: language }
    end
end) |> Enum.filter(fn
    %{ language: language, country: country } -> String.length(language) == 2 && String.length(country) == 2
    %{ language: language } -> String.length(language) == 2
end) |> Enum.uniq

for lang <- codes, do: Bonbon.Repo.insert! Bonbon.Model.Locale.changeset(%Bonbon.Model.Locale{}, lang)


Code.require_file("data_import.exs", "priv/repo")
Code.require_file("translation_data.exs", "priv/repo/data_import")
Code.require_file("ingredient_data.exs", "priv/repo/data_import")
Code.require_file("cuisine_data.exs", "priv/repo/data_import")

diets = Bonbon.Repo.DataImport.TranslationData.insert!(Bonbon.Model.Diet.Name.Translation, Bonbon.Repo.DataImport.load_diets)
for name <- diets do
    Bonbon.Repo.insert! Bonbon.Model.Diet.changeset(%Bonbon.Model.Diet{}, %{ name: name })
end

allergens = Bonbon.Repo.DataImport.TranslationData.insert!(Bonbon.Model.Allergen.Name.Translation, Bonbon.Repo.DataImport.load_allergens)
for name <- allergens do
    Bonbon.Repo.insert! Bonbon.Model.Allergen.changeset(%Bonbon.Model.Allergen{}, %{ name: name })
end

Bonbon.Repo.DataImport.IngredientData.insert!(Bonbon.Repo.DataImport.load_ingredients)

Bonbon.Repo.DataImport.CuisineData.insert!(Bonbon.Repo.DataImport.load_cuisines)

use Translecto.Query

locale = Bonbon.Model.Locale.to_locale_id!("en")

get_ingredient = fn name ->
    Bonbon.Repo.one! from ingredient in Bonbon.Model.Ingredient,
        locale: ^locale,
        translate: name in ingredient.name,
        where: name.term == ^name,
        select: ingredient.id
end

get_diet = fn name ->
    Bonbon.Repo.one! from diet in Bonbon.Model.Diet,
        locale: ^locale,
        translate: name in diet.name,
        where: name.term == ^name,
        select: diet.id
end

insert_food = fn cuisine, ingredients, diets, price, description ->
    [content|_] = for { code, desc } <- description do
        Bonbon.Repo.insert! Bonbon.Model.Item.Food.Content.Translation.changeset(%Bonbon.Model.Item.Food.Content.Translation{}, Map.new([{ :locale_id, Bonbon.Model.Locale.to_locale_id!(to_string(code)) }|desc]))
    end

    cuisine = Bonbon.Repo.one! from cuisine in Bonbon.Model.Cuisine,
        locale: ^locale,
        translate: name in cuisine.name,
        where: name.term == "pizza"

    food = Bonbon.Repo.insert! Bonbon.Model.Item.Food.changeset(%Bonbon.Model.Item.Food{}, %{ content: content.translate_id, cuisine_id: cuisine.id, available: true, price: Decimal.new(price), currency: "AUD", image: "image.jpg" })

    Enum.map(ingredients, &Bonbon.Repo.insert!(Bonbon.Model.Item.Food.IngredientList.changeset(%Bonbon.Model.Item.Food.IngredientList{}, %{ food_id: food.id, ingredient_id: get_ingredient.(&1) })))
    Enum.map(diets, &Bonbon.Repo.insert!(Bonbon.Model.Item.Food.DietList.changeset(%Bonbon.Model.Item.Food.DietList{}, %{ food_id: food.id, diet_id: get_diet.(&1) })))
end

insert_food.(
    "pizza",
    ["mozzarella", "basil", "tomato sauce"],
    ["lacto-vegetarian", "ovo-lacto-vegetarian"],
    10,
    en: [name: "Margherita Pizza", description: "An authentic Italian style margherita."]
)

insert_food.(
    "pizza",
    ["mozzarella", "pork", "tomato sauce"],
    [],
    12,
    en: [name: "Ham Pizza", description: "A cheese pizza with ham."]
)
