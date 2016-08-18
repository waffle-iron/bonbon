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
