defmodule Bonbon.API.Schema.Cuisine do
    use Absinthe.Schema
    use Translecto.Query
    import_types Bonbon.API.Schema.Cuisine.Region
    @moduledoc false

    @desc "An cuisine used in food"
    object :cuisine do
        field :id, :id, description: "The id of the cuisine"
        field :name, :string, description: "The name of the cuisine"
        field :region, :region, description: "The region of the cuisine"
    end

    @desc "A cuisine used in food"
    input_object :cuisine_input do
        field :id, :id, description: "The id of the cuisine"
        field :name, :string, description: "The name of the cuisine"
        field :region, :region_input, description: "The region of the cuisine"
    end

    def format(result), do: Map.merge(result, %{ region: Bonbon.API.Schema.Cuisine.Region.format(result.region) })

    def get(%{ id: id, locale: locale }, _) do
        query = from cuisine in Bonbon.Model.Cuisine,
            where: cuisine.id == ^id,
            locale: ^Bonbon.Model.Locale.to_locale_id!(locale),
            translate: name in cuisine.name,
            join: region in Bonbon.Model.Cuisine.Region, where: region.id == cuisine.region_id,
            translate: continent in region.continent,
            translate: subregion in region.subregion,
            translate: country in region.country,
            translate: province in region.province,
            select: %{
                id: cuisine.id,
                name: name.term,
                region: %{
                    id: region.id,
                    continent: continent.term,
                    subregion: subregion.term,
                    country: country.term,
                    province: province.term
                }
            }

        case Bonbon.Repo.one(query) do
            nil -> { :error, "Could not find cuisine" }
            result -> { :ok, format(result) }
        end
    end

    defp query_all(args = %{ find: find }) do
        find = find <> "%"
        where(query_all(Map.delete(args, :find)), [i, cn, r, c, s, n, p],
            ilike(cn.term, ^find) or
            ilike(c.term, ^find) or
            ilike(s.term, ^find) or
            ilike(n.term, ^find) or
            ilike(p.term, ^find)
        )
    end
    defp query_all(args = %{ name: name }) do
        name = name <> "%"
        where(query_all(Map.delete(args, :name)), [i, n], ilike(n.term, ^name))
    end
    defp query_all(args = %{ region: region }) do
        Enum.reduce(region, query_all(Map.delete(args, :region)), fn
            { :id, id }, query -> where(query, [i, cn, r, c, s, n, p], r.id == ^id)
            { :continent, continent }, query -> where(query, [i, cn, r, c, s, n, p], ilike(c.term, ^(continent <> "%")))
            { :subregion, subregion }, query -> where(query, [i, cn, r, c, s, n, p], ilike(s.term, ^(subregion <> "%")))
            { :country, country }, query -> where(query, [i, cn, r, c, s, n, p], ilike(n.term, ^(country <> "%")))
            { :province, province }, query -> where(query, [i, cn, r, c, s, n, p], ilike(p.term, ^(province <> "%")))
        end)
    end
    defp query_all(%{ locale: locale, limit: limit, offset: offset }) do
        from cuisine in Bonbon.Model.Cuisine,
            locale: ^Bonbon.Model.Locale.to_locale_id!(locale),
            translate: name in cuisine.name,
            join: region in Bonbon.Model.Cuisine.Region, on: region.id == cuisine.region_id,
            translate: continent in region.continent,
            translate: subregion in region.subregion,
            translate: country in region.country,
            translate: province in region.province,
            limit: ^limit,
            offset: ^offset, #todo: paginate
            select: %{
                id: cuisine.id,
                name: name.term,
                region: %{
                    id: region.id,
                    continent: continent.term,
                    subregion: subregion.term,
                    country: country.term,
                    province: province.term
                }
            }
    end

    def all(args, _) do
        case Bonbon.Repo.all(query_all(args)) do
            nil -> { :error, "Could not retrieve any cuisines" }
            result -> { :ok, Enum.map(result, &format/1) }
        end
    end
end
