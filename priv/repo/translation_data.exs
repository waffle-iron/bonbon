defmodule TranslationData do
    def insert!(model, data) do
        for { { _label, translation }, group } <- Enum.with_index(data) do
            insert!(model, translation, [], group + 1)
        end
        |> List.flatten
        |> Enum.filter_map(&(&1 != nil), &(&1.translate_id))
        |> Enum.uniq
    end

    def insert!(model, string, [_|language], group) when is_binary(string) do
        try do
            Bonbon.Model.Locale.to_locale_id(Enum.reverse(language) |> Enum.join("_"))
        else
            locale ->
                Bonbon.Repo.insert! model.changeset(struct(model), %{ term: string, locale_id: locale, translate_id: group })
        rescue
            _ -> nil
        end
    end
    def insert!(model, data, language, group) do
        for { locale, translation } <- data do
            insert!(model, translation, [to_string(locale)|language], group)
        end
    end
end
