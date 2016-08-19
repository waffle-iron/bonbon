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
import Ecto.Query
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
