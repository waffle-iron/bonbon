defmodule Bonbon.API.Schema.Allergen do
    use Absinthe.Schema
    use Translecto.Query
    @moduledoc false

    @desc "An allergy"
    object :allergen do
        field :id, :id, description: "The id of the allergen"
        field :name, :string, description: "The name of the allergen"
    end

    @desc "An allergy"
    input_object :allergen_input do
        field :id, :id, description: "The id of the allergen"
        field :name, :string, description: "The name of the allergen"
    end

    def get(%{ id: id, locale: locale }, _) do
        query = from allergen in Bonbon.Model.Allergen,
            where: allergen.id == ^id,
            locales: ^Bonbon.Model.Locale.to_locale_id_list!(locale),
            translate: name in allergen.name,
            select: %{
                id: allergen.id,
                name: name.term
            }

        case Bonbon.Repo.one(query) do
            nil -> { :error, "Could not find allergen" }
            result -> { :ok, result }
        end
    end

    defp query_all(args = %{ find: find }) do
        find = find <> "%"
        where(query_all(Map.delete(args, :find)), [i, n],
            ilike(n.term, ^find))
    end
    defp query_all(args = %{ name: name }) do
        name = name <> "%"
        where(query_all(Map.delete(args, :name)), [i, n], ilike(n.term, ^name))
    end
    defp query_all(%{ locale: locale, limit: limit, offset: offset }) do
        from allergen in Bonbon.Model.Allergen,
            locales: ^Bonbon.Model.Locale.to_locale_id_list!(locale),
            translate: name in allergen.name,
            limit: ^limit,
            offset: ^offset, #todo: paginate
            select: %{
                id: allergen.id,
                name: name.term
            }
    end

    def all(args, _) do
        case Bonbon.Repo.all(query_all(args)) do
            nil -> { :error, "Could not retrieve any allergens" }
            result -> { :ok, result }
        end
    end
end
