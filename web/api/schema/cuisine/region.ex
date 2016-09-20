defmodule Bonbon.API.Schema.Cuisine.Region do
    use Absinthe.Schema
    use Translecto.Query
    @moduledoc false

    @desc "A culinary region"
    object :region do
        field :id, :id, description: "The id of the region"
        field :continent, :string, description: "The continent of the region"
        field :subregion, :string, description: "The subregion of the region"
        field :country, :string, description: "The country of the region"
        field :province, :string, description: "The province of the region"
    end

    @desc "A culinary region"
    input_object :region_input do
        field :id, :id, description: "The id of the region"
        field :continent, :string, description: "The continent of the region"
        field :subregion, :string, description: "The subregion of the region"
        field :country, :string, description: "The country of the region"
        field :province, :string, description: "The province of the region"
    end

    def get(%{ id: id, locale: locale }, env) do
        query = from region in Bonbon.Model.Cuisine.Region,
            where: region.id == ^id,
            locale: ^Bonbon.Model.Locale.to_locale_id!(locale),
            translate: continent in region.continent,
            translate: subregion in region.subregion,
            translate: country in region.country,
            translate: province in region.province,
            select: %{
                id: region.id,
                continent: continent.term,
                subregion: subregion.term,
                country: country.term,
                province: province.term
            }

        case Bonbon.Repo.one(query) do
            nil -> { :error, "Could not find region" }
            result -> { :ok, result }
        end
    end

    defp query_all(args = %{ find: find }) do
        find = find <> "%"
        where(query_all(Map.delete(args, :find)), [i, c, s, n, p],
            ilike(c.term, ^find) or
            ilike(s.term, ^find) or
            ilike(n.term, ^find) or
            ilike(p.term, ^find)
        )
    end
    defp query_all(args = %{ continent: continent }) do
        continent = continent <> "%"
        where(query_all(Map.delete(args, :continent)), [i, c, s, n, p], ilike(c.term, ^continent))
    end
    defp query_all(args = %{ subregion: subregion }) do
        subregion = subregion <> "%"
        where(query_all(Map.delete(args, :subregion)), [i, c, s, n, p], ilike(s.term, ^subregion))
    end
    defp query_all(args = %{ country: country }) do
        country = country <> "%"
        where(query_all(Map.delete(args, :country)), [i, c, s, n, p], ilike(n.term, ^country))
    end
    defp query_all(args = %{ province: province }) do
        province = province <> "%"
        where(query_all(Map.delete(args, :province)), [i, c, s, n, p], ilike(p.term, ^province))
    end
    defp query_all(%{ locale: locale, limit: limit, offset: offset }) do
        from region in Bonbon.Model.Cuisine.Region,
            locale: ^Bonbon.Model.Locale.to_locale_id!(locale),
            translate: continent in region.continent,
            translate: subregion in region.subregion,
            translate: country in region.country,
            translate: province in region.province,
            limit: ^limit,
            offset: ^offset, #todo: paginate
            select: %{
                id: region.id,
                continent: continent.term,
                subregion: subregion.term,
                country: country.term,
                province: province.term
            }
    end

    def all(args, _) do
        case Bonbon.Repo.all(query_all(args)) do
            nil -> { :error, "Could not retrieve any regions" }
            result -> { :ok, result }
        end
    end
end
