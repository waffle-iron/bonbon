defmodule Bonbon.API.Schema.Diet do
    use Absinthe.Schema
    use Translecto.Query
    @moduledoc false

    @desc "A dietary restriction"
    object :diet do
        field :id, :id, description: "The id of the diet"
        field :name, :string, description: "The name of the diet"
    end

    @desc "A dietary restriction"
    input_object :diet_input do
        field :id, :id, description: "The id of the diet"
        field :name, :string, description: "The name of the diet"
    end

    def get(%{ id: id, locale: locale }, _) do
        query = from diet in Bonbon.Model.Diet,
            where: diet.id == ^id,
            locale: ^Bonbon.Model.Locale.to_locale_id!(locale),
            translate: name in diet.name,
            select: %{
                id: diet.id,
                name: name.term
            }

        case Bonbon.Repo.one(query) do
            nil -> { :error, "Could not find diet" }
            result -> { :ok, result }
        end
    end

    #defp query_all(args = %{ find: find }) do
    #    find = find <> "%"
    #    where(query_all(Map.delete(args, :find)), [i, n],
    #        ilike(n.term, ^find))
    #end
    defp query_all(args = %{ name: name }) do
        name = name <> "%"
        where(query_all(Map.delete(args, :name)), [i, n], ilike(n.term, ^name))
    end
    defp query_all(%{ locale: locale, limit: limit, offset: offset }) do
        from diet in Bonbon.Model.Diet,
            locale: ^Bonbon.Model.Locale.to_locale_id!(locale),
            translate: name in diet.name,
            limit: ^limit,
            offset: ^offset, #todo: paginate
            select: %{
                id: diet.id,
                name: name.term
            }
    end

    def all(args, _) do
        case Bonbon.Repo.all(query_all(args)) do
            nil -> { :error, "Could not retrieve any diets" }
            result -> { :ok, result }
        end
    end
end
