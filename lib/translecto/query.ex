defmodule Translecto.Query do
    defmacro __using__(options) do
        quote do
            import Translecto.Query
            import Ecto.Query, except: [from: 2]
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

    defmacro from(expr, kw \\ []) do
        quote do
            Ecto.Query.from(unquote(expr), unquote(expand_translate_query(kw, [get_table(expr)])))
        end
    end
end
