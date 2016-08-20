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
end
