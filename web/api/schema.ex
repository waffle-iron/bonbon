defmodule Bonbon.API.Schema do
    use Absinthe.Schema
    use Translecto.Query

    query do
        @desc "Get an ingredient by id" #Absinthe.run ~S[{ ingredient(id: 1, locale: "en"){ name } }], Bonbon.API.Schema
        field :ingredient, type: :ingredient do
            @desc "The locale to return the ingredient in"
            arg :locale, :string

            @desc "The id of the ingredient"
            arg :id, :id

            resolve fn
                %{ id: user_id, locale: locale }, _ ->
                    query = from ingredient in Bonbon.Model.Ingredient,
                        where: ingredient.id == ^user_id,
                        locale: ^Bonbon.Model.Locale.to_locale_id(locale),
                        translate: name in ingredient.name,
                        translate: type in ingredient.type,
                        select: %{
                            id: ingredient.id,
                            name: name.term,
                            type: type.term
                        }

                    case Bonbon.Repo.one(query) do
                        nil -> { :error, "Could not find ingredient" }
                        result -> { :ok, result }
                    end
            end
        end
    end

    @desc "An ingredient used in the food"
    object :ingredient do
        field :id, :id, description: "The id of the ingredient"
        field :name, :string, description: "The name of the ingredient"
        field :type, :string, description: "The culinary type of the ingredient"
    end
end
