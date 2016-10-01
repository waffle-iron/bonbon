defmodule Bonbon.Repo.DataImport.CuisineData do
    Code.require_file("translation_data.exs", "priv/repo/data_import")

    def insert!(data) do
        Map.new(for value <- data do
            value
            |> insert_translation!
            |> insert_cuisine!
        end)
    end

    defp insert_cuisine!(data, type \\ [])
    defp insert_cuisine!(info = %{ cuisine: cuisine }, _) do
        %{
            info | cuisine: Map.new(Enum.map(cuisine, fn { key, value } ->
                { key, Map.put(value, :id, Bonbon.Repo.insert!(Bonbon.Model.Cuisine.changeset(%Bonbon.Model.Cuisine{}, %{ name: value.translation, region_id: info.id })).id) }
            end))
        }
    end
    defp insert_cuisine!(info = %{}, _), do: info
    defp insert_cuisine!({ :__info__, info }, type) do
        regions = Map.new(Enum.zip([:continent, :subregion, :country, :province], Enum.reverse(type)))
        { :__info__, insert_cuisine!(Map.put(info, :id, Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.changeset(%Bonbon.Model.Cuisine.Region{}, regions)).id)) }
    end
    defp insert_cuisine!({ key, value }, type) do
        { key, Map.new(Enum.map(value, &(insert_cuisine!(&1, [value.__info__.translation|type])))) }
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
