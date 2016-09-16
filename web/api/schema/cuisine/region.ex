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
end
