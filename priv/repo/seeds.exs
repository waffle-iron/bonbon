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


Code.require_file("translation_data.exs", "priv/repo")

diets = TranslationData.insert!(Bonbon.Model.Diet.Name.Translation, File.read!("datasources/Food-Data/translations/diet-names.toml") |> Tomlex.load)
for name <- diets do
    Bonbon.Repo.insert! Bonbon.Model.Diet.changeset(%Bonbon.Model.Diet{}, %{ name: name })
end

allergens = TranslationData.insert!(Bonbon.Model.Allergen.Name.Translation, File.read!("datasources/Food-Data/translations/allergen-names.toml") |> Tomlex.load)
for name <- allergens do
    Bonbon.Repo.insert! Bonbon.Model.Allergen.changeset(%Bonbon.Model.Allergen{}, %{ name: name })
end

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
query = from locale in Bonbon.Model.Locale, select: locale.id
for { ingredient, group } <- Enum.with_index(ingredient_names, 1) do
    for name <- ingredient do
        query = if name.country == nil do
            where(query, [locale], is_nil(locale.country))
        else
            where(query, [country: ^name.country])
        end

        locale = Bonbon.Repo.one!(where(query, [language: ^name.language]))
        Bonbon.Repo.insert! Bonbon.Model.Ingredient.Name.Translation.changeset(%Bonbon.Model.Ingredient.Name.Translation{}, %{ term: name.term, locale_id: locale, translate_id: group })
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
query = from locale in Bonbon.Model.Locale, select: locale.id
for { ingredient, group } <- Enum.with_index(ingredient_types, 1) do
    for type <- ingredient do
        query = if type.country == nil do
            where(query, [locale], is_nil(locale.country))
        else
            where(query, [country: ^type.country])
        end

        locale = Bonbon.Repo.one!(where(query, [language: ^type.language]))
        Bonbon.Repo.insert! Bonbon.Model.Ingredient.Type.Translation.changeset(%Bonbon.Model.Ingredient.Type.Translation{}, %{ term: type.term, locale_id: locale, translate_id: group })
    end
end

Bonbon.Repo.insert! Bonbon.Model.Ingredient.changeset(%Bonbon.Model.Ingredient{}, %{ type: 2, name: 3 })
Bonbon.Repo.insert! Bonbon.Model.Ingredient.changeset(%Bonbon.Model.Ingredient{}, %{ type: 2, name: 2 })
Bonbon.Repo.insert! Bonbon.Model.Ingredient.changeset(%Bonbon.Model.Ingredient{}, %{ type: 4, name: 1 })


#Should store this in an external file https://en.wikipedia.org/wiki/Cuisine
continents = [
    [
        %{ language: "en", country: nil, term: "african" }
    ],
    [
        %{ language: "en", country: nil, term: "asian" }
    ],
    [
        %{ language: "en", country: nil, term: "european" }
    ],
    [
        %{ language: "en", country: nil, term: "oceanian" }
    ],
    [
        %{ language: "en", country: nil, term: "americas" }
    ]
]
#todo: Optimize it does not need to query
query = from locale in Bonbon.Model.Locale, select: locale.id
for { continent, group } <- Enum.with_index(continents, 1) do
    for name <- continent do
        query = if name.country == nil do
            where(query, [locale], is_nil(locale.country))
        else
            where(query, [country: ^name.country])
        end

        locale = Bonbon.Repo.one!(where(query, [language: ^name.language]))
        Bonbon.Repo.insert! Bonbon.Model.Cuisine.Region.Continent.Translation.changeset(%Bonbon.Model.Cuisine.Region.Continent.Translation{}, %{ term: name.term, locale_id: locale, translate_id: group })
    end
end

#Should store this in an external file
#https://en.wikipedia.org/wiki/List_of_African_cuisines
#https://en.wikipedia.org/wiki/List_of_Asian_cuisines
#https://en.wikipedia.org/wiki/List_of_European_cuisines
#https://en.wikipedia.org/wiki/Oceanic_cuisine
#https://en.wikipedia.org/wiki/List_of_cuisines_of_the_Americas
subregions = [
    #African
    [
        %{ language: "en", country: nil, term: "central africa" }
    ],
    [
        %{ language: "en", country: nil, term: "east africa" }
    ],
    #Asian
    [
        %{ language: "en", country: nil, term: "central asia" }
    ],
    [
        %{ language: "en", country: nil, term: "east asia" }
    ],
    #European
    [
        %{ language: "en", country: nil, term: "central europe" }
    ],
    [
        %{ language: "en", country: nil, term: "east europe" }
    ],
    #Oceanic
    #Americas
    [
        %{ language: "en", country: nil, term: "north america" }
    ],
    [
        %{ language: "en", country: nil, term: "central america" }
    ]
]
#todo: Optimize it does not need to query
query = from locale in Bonbon.Model.Locale, select: locale.id
for { subregion, group } <- Enum.with_index(subregions, 1) do
    for name <- subregion do
        query = if name.country == nil do
            where(query, [locale], is_nil(locale.country))
        else
            where(query, [country: ^name.country])
        end

        locale = Bonbon.Repo.one!(where(query, [language: ^name.language]))
        Bonbon.Repo.insert! Bonbon.Model.Cuisine.Region.Subregion.Translation.changeset(%Bonbon.Model.Cuisine.Region.Subregion.Translation{}, %{ term: name.term, locale_id: locale, translate_id: group })
    end
end

#countries
#provinces

#regional variants
Bonbon.Repo.insert! Bonbon.Model.Cuisine.Region.changeset(%Bonbon.Model.Cuisine.Region{}, %{ continent: 1, subregion: nil, country: nil, province: nil })
Bonbon.Repo.insert! Bonbon.Model.Cuisine.Region.changeset(%Bonbon.Model.Cuisine.Region{}, %{ continent: 1, subregion: 1, country: nil, province: nil })
Bonbon.Repo.insert! Bonbon.Model.Cuisine.Region.changeset(%Bonbon.Model.Cuisine.Region{}, %{ continent: 1, subregion: 2, country: nil, province: nil })

Bonbon.Repo.insert! Bonbon.Model.Cuisine.Region.changeset(%Bonbon.Model.Cuisine.Region{}, %{ continent: 2, subregion: nil, country: nil, province: nil })
Bonbon.Repo.insert! Bonbon.Model.Cuisine.Region.changeset(%Bonbon.Model.Cuisine.Region{}, %{ continent: 2, subregion: 3, country: nil, province: nil })
Bonbon.Repo.insert! Bonbon.Model.Cuisine.Region.changeset(%Bonbon.Model.Cuisine.Region{}, %{ continent: 2, subregion: 4, country: nil, province: nil })

Bonbon.Repo.insert! Bonbon.Model.Cuisine.Region.changeset(%Bonbon.Model.Cuisine.Region{}, %{ continent: 3, subregion: nil, country: nil, province: nil })
Bonbon.Repo.insert! Bonbon.Model.Cuisine.Region.changeset(%Bonbon.Model.Cuisine.Region{}, %{ continent: 3, subregion: 5, country: nil, province: nil })
Bonbon.Repo.insert! Bonbon.Model.Cuisine.Region.changeset(%Bonbon.Model.Cuisine.Region{}, %{ continent: 3, subregion: 6, country: nil, province: nil })

Bonbon.Repo.insert! Bonbon.Model.Cuisine.Region.changeset(%Bonbon.Model.Cuisine.Region{}, %{ continent: 4, subregion: nil, country: nil, province: nil })

Bonbon.Repo.insert! Bonbon.Model.Cuisine.Region.changeset(%Bonbon.Model.Cuisine.Region{}, %{ continent: 5, subregion: nil, country: nil, province: nil })
Bonbon.Repo.insert! Bonbon.Model.Cuisine.Region.changeset(%Bonbon.Model.Cuisine.Region{}, %{ continent: 5, subregion: 7, country: nil, province: nil })
Bonbon.Repo.insert! Bonbon.Model.Cuisine.Region.changeset(%Bonbon.Model.Cuisine.Region{}, %{ continent: 5, subregion: 8, country: nil, province: nil })

#cuisines
query = from locale in Bonbon.Model.Locale,
    where: locale.language == "en" and is_nil(locale.country),
    select: locale.id

locale = Bonbon.Repo.one!(query)

Bonbon.Repo.insert! Bonbon.Model.Cuisine.Name.Translation.changeset(%Bonbon.Model.Cuisine.Name.Translation{}, %{ term: "poutine", locale_id: locale })
Bonbon.Repo.insert! Bonbon.Model.Cuisine.Name.Translation.changeset(%Bonbon.Model.Cuisine.Name.Translation{}, %{ term: "eggs benedict", locale_id: locale })
Bonbon.Repo.insert! Bonbon.Model.Cuisine.Name.Translation.changeset(%Bonbon.Model.Cuisine.Name.Translation{}, %{ term: "sushi", locale_id: locale })

Bonbon.Repo.insert! Bonbon.Model.Cuisine.changeset(%Bonbon.Model.Cuisine{}, %{ name: 1, region_id: 12 })
Bonbon.Repo.insert! Bonbon.Model.Cuisine.changeset(%Bonbon.Model.Cuisine{}, %{ name: 2, region_id: 12 })
Bonbon.Repo.insert! Bonbon.Model.Cuisine.changeset(%Bonbon.Model.Cuisine{}, %{ name: 3, region_id: 5 })
