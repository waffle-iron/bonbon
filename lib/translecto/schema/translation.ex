defmodule Translecto.Schema.Translation do
    import Ecto.Schema

    defmacro __using__(options) do
        pkey = if Keyword.get(options, :primary_key, true) do
            quote do: @primary_key { :translate_id, :id, autogenerate: true }
        end

        quote do
            import Translecto.Schema.Translation
            import Translecto.Changeset

            unquote(pkey)
        end
    end

    defmacro translation(opts \\ []) do
        quote do
            belongs_to :locale, Bonbon.Locale
        end
    end
end
