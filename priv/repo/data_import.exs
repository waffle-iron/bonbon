defmodule Bonbon.Repo.DataImport do
    defp load(path), do: File.read!(path) |> Tomlex.load

    @path "datasources/Food-Data"
    def load_diets(), do: load(Path.join(@path, "translations/diet-names.toml"))

    def load_allergens(), do: load(Path.join(@path, "translations/allergen-names.toml"))

    def load_ingredients(), do: load_tree(Path.join(@path, "ingredients"))

    def load_cuisines(), do: load_tree(Path.join(@path, "cuisines"))

    defp load_tree(path) do
        Path.wildcard(Path.join(path, "**/*.toml"))
        |> Enum.reduce(%{}, fn file, acc ->
            [_|paths] = Enum.reverse(Path.split(Path.relative_to(file, path)))
            contents = Enum.reduce([Path.basename(file, ".toml")|paths], %{ __info__: load(file) }, fn name, contents ->
                %{ name => contents }
            end)

            Map.merge(acc, contents, &merge_nested_contents/3)
        end)
    end

    defp merge_nested_contents(_key, a, b), do: Map.merge(a, b, &merge_nested_contents/3)
end
