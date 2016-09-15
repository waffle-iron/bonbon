defmodule Bonbon.API.Schema do
    use Absinthe.Schema
    import_types Bonbon.API.Schema.Ingredient

    query do
        @desc "Get an ingredient by id"
        field :ingredient, type: :ingredient do
            @desc "The locale to return the ingredient in"
            arg :locale, :string, default_value: "en"

            @desc "The id of the ingredient"
            arg :id, :id

            resolve &Bonbon.API.Schema.Ingredient.get/2
        end

        @desc "Get all the available ingredients"
        field :ingredients, type: list_of(:ingredient) do
            @desc "The locale to return the ingredients in"
            arg :locale, :string, default_value: "en"

            @desc "The number of ingredients to get"
            arg :limit, :integer, default_value: 50

            @desc "The offset of first ingredient to get"
            arg :offset, :integer, default_value: 0

            @desc "The name to match against"
            arg :name, :string

            @desc "The type to match against"
            arg :type, :string

            resolve &Bonbon.API.Schema.Ingredient.all/2
        end
    end
end
