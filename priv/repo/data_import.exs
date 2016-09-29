defmodule Bonbon.Repo.DataImport do
    @path "datasources/Food-Data/translations"

    defp load(path), do: File.read!(path) |> Tomlex.load

    def load_diets(), do: Path.join(@path, "diet-names.toml") |> load

    def load_allergens(), do: Path.join(@path, "allergen-names.toml") |> load
end
