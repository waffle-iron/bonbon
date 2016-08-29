defmodule Translecto.Schema.Translation do
    import Ecto.Schema
    @moduledoc """
      Sets up a translation schema.

      This module coincides with the migration function `Translecto.Migration.translation/1`.
      To correctly use this module a schema should call `use Translecto.Schema.Translation`,
      overriding the default primary_key behaviour if needed and then adding the `translation/0`
      macro to the schema.
    """

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

    @doc """
      Setup the schema as a translation.

        defmodule Ingredient.Translation do
            use Translecto.Schema.Translation

            schema "ingredient_translations" do
                translation
                field :term, :string
            end

            def changeset(struct, params \\\\ %{}) do
                struct
                |> translation_changeset(params)
                |> cast(params, [:term])
                |> validate_required([:term])
            end
        end
    """
    defmacro translation(opts \\ []) do
        quote do
            belongs_to :locale, Bonbon.Model.Locale
        end
    end
end
