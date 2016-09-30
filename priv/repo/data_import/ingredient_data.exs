defmodule Bonbon.Repo.DataImport.IngredientData do
    Code.require_file("translation_data.exs", "priv/repo/data_import")

    def insert!(data) do
        Map.new(for value <- data do
            value
            |> insert_translation!
            |> insert_ingredient!
        end)
    end

    defp insert_ingredient!(data, type \\ nil, group \\ nil)
    defp insert_ingredient!(info = { :__info__, _ }, :group, _), do: info
    defp insert_ingredient!({ :__info__, info }, :ingredient, group) do
        { :__info__, Map.put(info, :id, Bonbon.Repo.insert!(Bonbon.Model.Ingredient.changeset(%Bonbon.Model.Ingredient{}, %{ type: group, name: info.translation })).id) }
    end
    defp insert_ingredient!({ key, value }, _, group) do
        { type, group } = case Map.keys(value) do #todo: should probably specify in info what type it is
            [:__info__] -> { :ingredient, group }
            _ -> { :group, value.__info__.translation }
        end

        { key, Map.new(Enum.map(value, &(insert_ingredient!(&1, type, group)))) }
    end

    defp insert_translation!(data, type \\ nil)
    defp insert_translation!({ :__info__, info }, :group) do
        { :__info__, %{ info | translation: Bonbon.Repo.DataImport.TranslationData.insert!(Bonbon.Model.Ingredient.Type.Translation, info.translation, nil) } }
    end
    defp insert_translation!({ :__info__, info }, :ingredient) do
        { :__info__, %{ info | translation: Bonbon.Repo.DataImport.TranslationData.insert!(Bonbon.Model.Ingredient.Name.Translation, info.translation, nil) } }
    end
    defp insert_translation!({ key, value }, _) do
        type = case Map.keys(value) do #todo: should probably specify in info what type it is
            [:__info__] -> :ingredient
            _ -> :group
        end

        { key, Map.new(Enum.map(value, &(insert_translation!(&1, type)))) }
    end
end
