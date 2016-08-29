defmodule Translecto.Query do
    @moduledoc """
      Provides convenient functionality for querying translatable models.
    """
    defmacro __using__(options) do
        quote do
            import Translecto.Query
            import Ecto.Query, except: [from: 1, from: 2]
        end
    end

    defp get_table({ :in, _, [{ ref, _, _ }, data] }), do: { ref, data }

    defp expand_translate_query(kw, tables, locale \\ 1), do: Enum.reverse(expand_translate_query(kw, tables, locale, []))

    defp expand_translate_query([], _, _, acc), do: acc
    defp expand_translate_query([{ :translate, { :in, _, [name, { { :., _, [table_name = { table, _, _ }, field] }, _, _ }] } }|kw], tables, locale, acc) do
        expand_translate_query(kw, tables, locale, [quote do
            { :where, unquote(table_name).unquote(field) == unquote(name).translate_id and unquote(name).locale_id == unquote(locale) }
        end, quote do
            { :join, unquote(name) in ^unquote(tables[table]).get_translation(unquote(field)) }
        end|acc])
    end
    defp expand_translate_query([expr = { :join, table }|kw], tables, locale, acc) do
        expand_translate_query(kw, [get_table(table)|tables], locale, [expr|acc])
    end
    defp expand_translate_query([{ :locale, locale }|kw], tables, _, acc), do: expand_translate_query(kw, tables, locale, acc)
    defp expand_translate_query([expr|kw], tables, locale, acc), do: expand_translate_query(kw, tables, locale, [expr|acc])

    @doc """
      Create a query.

      It allows for the standard [`Ecto.Query.from/2`](https://hexdocs.pm/ecto/Ecto.Query.html#from/2)
      query syntax and functionality to be used. But adds support for two new expressions `locale` and
      `translate`, aimed at simplifying making translatable queries.

      A translatable query is structured as follows:

        \# Get the english names for all ingredients.
        from ingredient in Model.Ingredient,
            locale: ^en.id,
            translate: name in ingredient.name,
            select: name.term

      A translatable query requires a locale to be set using the `:locale` keyword. This value should be
      the locale value that will be matched in the translation model's for `:locale_id` field.

      The `:translate` keyword is used to create access to any translatable terms. It takes the form of
      an `in` expression where the left argument is the named reference to that translation, and the
      right argument is the translatable field (field marked as `Translecto.Schema.Translatable.translatable/3`).

      After using translate the translatable term(s) for that field are now available throughout the query,
      in the given locale specified.

        \# Get the ingredient whose english name matches "orange"
        from ingredient in Model.Ingredient,
            locale: ^en.id,
            translate: name in ingredient.name, where: name.term == "orange",
            select: ingredient

      Multiple translates can be used together in the same expression to translate as many fields of
      the translatable fields as needed.
    """
    @spec from(any, keyword()) :: Macro.t
    defmacro from(expr, kw \\ []) do
        quote do
            Ecto.Query.from(unquote(expr), unquote(expand_translate_query(kw, [get_table(expr)])))
        end
    end
end
