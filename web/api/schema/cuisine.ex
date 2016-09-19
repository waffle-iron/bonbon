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
            result -> { :ok, result }
        end
    end
end
