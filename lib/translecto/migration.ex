defmodule Translecto.Migration do
    import Ecto.Migration
    @moduledoc """
      Provides convenient functionality for creating tables that support translatable
      data.
    """

    @doc """
      Setup the table as a translation lookup. All fields in this table will now be
      translatable.

      Translation groups (groups of equivalent data) are specified using the
      `:translate_id` field. While the different translations for those individual
      groups is specified using the `:locale_id`, which contains a reference to the
      `:locales` table.

      Unless overriden in the options, the table should have its default primary key
      set to false. While the new `:translate_id` and `:locale_id` fields become the
      composite primary keys.

        create table(:ingredient_name_translations, primary_key: false) do
            translation
            add :term, :string, null: false
        end
    """
    @spec translation(keyword()) :: no_return
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

    @doc """
      Add a translatable field to a given table.

      This indicates that the field should be translated to access its contents. That
      it is a reference to a translation table.

        create table(:ingredients) do
            translate :name, null: false
        end
    """
    @spec translate(atom, keyword()) :: no_return
    def translate(column, opts \\ []) do
        add column, :id, opts
    end
end
