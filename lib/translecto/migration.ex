defmodule Translecto.Migration do
    import Ecto.Migration

    def translation(opts \\ []) do
        add :translate_id, :serial,
            Keyword.merge([
                primary_key: true,
                # comment: "The translation group for this entry"
            ], opts)

        add :locale_id, references(:locales),
            Keyword.merge([
                primary_key: true,
                # comment: "The language locale for this entry"
            ], opts)
    end

    def translate(column, opts \\ []) do
        add column, :id, opts
    end
end
