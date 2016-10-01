defmodule Bonbon.Repo.DataImport.CuisineData do
    Code.require_file("translation_data.exs", "priv/repo/data_import")

    def insert!(data) do
        Map.new(for value <- data do
            value
            |> insert_translation!
        end)
    end

    defp insert_translation!(data, type \\ [nil, :continent, :subregion, :country, :province])
    defp insert_translation!(info = %{ cuisine: cuisine }, :cuisine) do
        %{
            info | cuisine: Map.new(Enum.map(cuisine, fn { key, info } ->
                { key, %{ info | translation: Bonbon.Repo.DataImport.TranslationData.insert!(Bonbon.Model.Cuisine.Name.Translation, info.translation, nil) } }
            end))
        }
    end
    defp insert_translation!(info, :cuisine), do: info
    defp insert_translation!({ :__info__, info }, [:province|_]) do
        { :__info__, %{ insert_translation!(info, :cuisine) | translation: Bonbon.Repo.DataImport.TranslationData.insert!(Bonbon.Model.Cuisine.Region.Province.Translation, info.translation, nil, "adj") } }
    end
    defp insert_translation!({ :__info__, info }, [:country|_]) do
        { :__info__, %{ insert_translation!(info, :cuisine) | translation: Bonbon.Repo.DataImport.TranslationData.insert!(Bonbon.Model.Cuisine.Region.Country.Translation, info.translation, nil, "adj") } }
    end
    defp insert_translation!({ :__info__, info }, [:subregion|_]) do
        { :__info__, %{ insert_translation!(info, :cuisine) | translation: Bonbon.Repo.DataImport.TranslationData.insert!(Bonbon.Model.Cuisine.Region.Subregion.Translation, info.translation, nil, "adj") } }
    end
    defp insert_translation!({ :__info__, info }, [:continent|_]) do
        { :__info__, %{ insert_translation!(info, :cuisine) | translation: Bonbon.Repo.DataImport.TranslationData.insert!(Bonbon.Model.Cuisine.Region.Continent.Translation, info.translation, nil, "adj") } }
    end
    defp insert_translation!({ key, value }, [_|type]) do
        { key, Map.new(Enum.map(value, &(insert_translation!(&1, type)))) }
    end
end
