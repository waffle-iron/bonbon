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
