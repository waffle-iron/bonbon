defmodule Translecto.Schema.Translatable do
    import Ecto.Schema

    defmacro __using__(options) do
        quote do
            import Translecto.Schema.Translatable
            import Translecto.Changeset

            @before_compile unquote(__MODULE__)
        end
    end

    defmacro __before_compile__(env) do
        quote do
            unquote(Enum.map(Module.get_attribute(env.module, :translecto_translate), fn { name, queryable } ->
                quote do
                    def get_translation(unquote(name)) do
                        unquote(queryable)
                    end
                end
            end))
        end
    end

    defmacro translatable(name, queryable, opts \\ []) do
        Module.put_attribute(__CALLER__.module, :translecto_translate, [{ name, queryable }|(Module.get_attribute(__CALLER__.module, :translecto_translate) || [])])

        quote do
            field unquote(name), :id
        end
    end
end
