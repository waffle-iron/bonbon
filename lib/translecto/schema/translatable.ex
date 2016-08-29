defmodule Translecto.Schema.Translatable do
    import Ecto.Schema
    @moduledoc """
      Reference a translatable field in the schema.

      This module coincides with the migration function `Translecto.Migration.translate/2`.
      To correctly use this module a schema should call `use Translecto.Schema.Translatable`.
    """

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

    @doc """
      Expose a field as being translatable to the schema.

      The name of the field specified should coincide with a migration table field that was made
      using `Translecto.Migration.translate/2`.

      The queryable should be the translation module (schema) that represents the translation table.

        defmodule Ingredient do
            use Translecto.Schema.Translatable

            schema "ingredients" do
                translatable :name, Ingredient.Translation
            end

            def changeset(struct, params \\\\ %{}) do
                struct
                |> translatable_changeset(params, [:name])
                |> validate_required([:name])
            end
        end
    """
    @spec translatable(atom, module(), keyword()) :: Macro.t
    defmacro translatable(name, queryable, opts \\ []) do
        Module.put_attribute(__CALLER__.module, :translecto_translate, [{ name, queryable }|(Module.get_attribute(__CALLER__.module, :translecto_translate) || [])])

        quote do
            field unquote(name), :id
        end
    end
end
