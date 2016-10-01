defmodule Bonbon.Repo.DataImport.TranslationData do
    def insert!(model, data) do
        for { _label, translation } <- data do
            insert!(model, translation, nil)
        end
        |> Enum.filter(&(&1 != nil))
    end

    def insert!(model, translation, group, field \\ "term", language \\ [])
    def insert!(model, string, group, field, [field|language]) when is_binary(string) do
        try do
            Bonbon.Model.Locale.to_locale_id!(Enum.reverse(language) |> Enum.join("_"))
        else
            locale ->
                Bonbon.Repo.insert!(model.changeset(struct(model), %{ term: string, locale_id: locale, translate_id: group })).translate_id
        rescue
            _ -> nil
        end
    end
    def insert!(_, string, _, _, _) when is_binary(string), do: nil
    def insert!(model, data, group, field, language) do
        Enum.reduce(data, group, fn { locale, translation }, group ->
            case insert!(model, translation, group, field, [to_string(locale)|language]) do
                nil -> group
                translation -> translation
            end
        end)
    end
end
