defmodule Bonbon.Repo.DataImport.IngredientData do
    Code.require_file("translation_data.exs", "priv/repo/data_import")

    def insert!(data) do
        Enum.map(data, &insert_translation!(&1, nil))
        |> Map.new
    end

    defp insert_translation!({ :__info__, info }, :group) do
        { :__info__, %{ info | translation: Bonbon.Repo.DataImport.TranslationData.insert!(Bonbon.Model.Ingredient.Type.Translation, info.translation, nil) } }
    end
    defp insert_translation!({ :__info__, info }, :ingredient) do
        { :__info__, %{ info | translation: Bonbon.Repo.DataImport.TranslationData.insert!(Bonbon.Model.Ingredient.Name.Translation, info.translation, nil) } }
    end
    defp insert_translation!({ key, value }, group) do
        type = case Map.keys(value) do #todo: should probably specify in info what type it is
            [:__info__] -> :ingredient
            _ -> :group
        end

        { key, Map.new(Enum.map(value, &(insert_translation!(&1, type)))) }
    end
end
