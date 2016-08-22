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

for lang <- codes, do: Bonbon.Repo.insert! Bonbon.Locale.changeset(%Bonbon.Locale{}, lang)


#Should store this in an external file
ingredient_names = [
    [
        %{ language: "en", country: nil, term: "blue cheese" },
        %{ language: "fr", country: nil, term: "fromage bleu" }
    ],
    [
        %{ language: "en", country: nil, term: "orange" },
        %{ language: "fr", country: nil, term: "orange" }
    ],
    [
        %{ language: "en", country: nil, term: "lemon" },
        %{ language: "fr", country: nil, term: "citron" }
    ]
]
#todo: Optimize it does not need to query
use Translecto.Query
query = from locale in Bonbon.Locale, select: locale.id
for { ingredient, group } <- Enum.with_index(ingredient_names, 1) do
    for name <- ingredient do
        query = if name.country == nil do
            where(query, [locale], is_nil(locale.country))
        else
            where(query, [country: ^name.country])
        end

        locale = Bonbon.Repo.one!(where(query, [language: ^name.language]))
        Bonbon.Repo.insert! Bonbon.IngredientNameTranslation.changeset(%Bonbon.IngredientNameTranslation{}, %{ term: name.term, locale_id: locale, translate_id: group })
    end
end


#Should store this in an external file https://en.wikipedia.org/wiki/Lists_of_foods
ingredient_types = [
    [
        %{ language: "en", country: nil, term: "meat" },
        %{ language: "fr", country: nil, term: "viande" }
    ],
    [
        %{ language: "en", country: nil, term: "fruit" },
        %{ language: "fr", country: nil, term: "fruit" }
    ],
    [
        %{ language: "en", country: nil, term: "vegetable" },
        %{ language: "fr", country: nil, term: "légume" }
    ],
    [
        %{ language: "en", country: nil, term: "dairy" },
        %{ language: "fr", country: nil, term: "produits laitiers" }
    ]
]
#todo: Optimize it does not need to query
query = from locale in Bonbon.Locale, select: locale.id
for { ingredient, group } <- Enum.with_index(ingredient_types, 1) do
    for type <- ingredient do
        query = if type.country == nil do
            where(query, [locale], is_nil(locale.country))
        else
            where(query, [country: ^type.country])
        end

        locale = Bonbon.Repo.one!(where(query, [language: ^type.language]))
        Bonbon.Repo.insert! Bonbon.IngredientTypeTranslation.changeset(%Bonbon.IngredientTypeTranslation{}, %{ term: type.term, locale_id: locale, translate_id: group })
    end
end


Bonbon.Repo.insert! Bonbon.Ingredient.changeset(%Bonbon.Ingredient{}, %{ type: 2, name: 3 })
Bonbon.Repo.insert! Bonbon.Ingredient.changeset(%Bonbon.Ingredient{}, %{ type: 2, name: 2 })
Bonbon.Repo.insert! Bonbon.Ingredient.changeset(%Bonbon.Ingredient{}, %{ type: 4, name: 1 })

#Get ingredient names in the given language locale: "en"
locale = Bonbon.Repo.one!(from locale in Bonbon.Locale, select: locale.id, where: locale.language == "en" and is_nil(locale.country))
query = from ingredient in Bonbon.Ingredient,
    locale: ^locale,
    translate: name in ingredient.name,
    select: name.term

Bonbon.Repo.all(query) |> IO.inspect

#Find ingredient with name in the given language locale: "en"
find = "lemon"
locale = Bonbon.Repo.one!(from locale in Bonbon.Locale, select: locale.id, where: locale.language == "en" and is_nil(locale.country))
query = from ingredient in Bonbon.Ingredient,
    locale: ^locale,
    translate: name in ingredient.name, where: name.term == ^find,
    select: name.term

Bonbon.Repo.all(query) |> IO.inspect

#Find ingredient with name in the given language locale: "fr"
find = "citron"
locale = Bonbon.Repo.one!(from locale in Bonbon.Locale, select: locale.id, where: locale.language == "fr" and is_nil(locale.country))
query = from ingredient in Bonbon.Ingredient,
    locale: ^locale,
    translate: name in ingredient.name, where: name.term == ^find,
    translate: type in ingredient.type,
    select: { name.term, type.term }

Bonbon.Repo.all(query) |> IO.inspect


table = Bonbon.Ingredient
query = from ingredient in table,
    locale: ^locale,
    translate: name in ingredient.name, where: name.term == ^find,
    translate: type in ingredient.type,
    select: { name.term, type.term }

Bonbon.Repo.all(query) |> IO.inspect
