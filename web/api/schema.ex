defmodule Bonbon.API.Schema do
    use Absinthe.Schema
    import_types Bonbon.API.Schema.Ingredient
    import_types Bonbon.API.Schema.Cuisine.Region

    defmacrop show_exception_messages(fun) do
        quote do
            fn args, env -> show_exception_messages(args, env, unquote(fun)) end
        end
    end

    query do
        #ingredient
        @desc "Get an ingredient by id"
        field :ingredient, type: :ingredient do
            @desc "The locale to return the ingredient in"
            arg :locale, :string, default_value: "en"

            @desc "The id of the ingredient"
            arg :id, :id

            resolve show_exception_messages(&Bonbon.API.Schema.Ingredient.get/2)
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

            resolve show_exception_messages(&Bonbon.API.Schema.Ingredient.all/2)
        end

        #cuisine regions
        @desc "Get a culinary region by id"
        field :region, type: :region do
            @desc "The locale to return the region in"
            arg :locale, :string, default_value: "en"

            @desc "The id of the region"
            arg :id, :id

            resolve show_exception_messages(&Bonbon.API.Schema.Cuisine.Region.get/2)
        end

        @desc "Get all the available culinary regions"
        field :regions, type: list_of(:region) do
            @desc "The locale to return the regions in"
            arg :locale, :string, default_value: "en"

            @desc "The number of regions to get"
            arg :limit, :integer, default_value: 50

            @desc "The offset of first region to get"
            arg :offset, :integer, default_value: 0

            @desc "The continent to match against"
            arg :continent, :string

            @desc "The subregion to match against"
            arg :subregion, :string

            @desc "The country to match against"
            arg :country, :string

            @desc "The province to match against"
            arg :province, :string

            @desc "The region to match against (continent, subregion, country, province)"
            arg :find, :string

            resolve show_exception_messages(&Bonbon.API.Schema.Cuisine.Region.all/2)
        end
    end

    defp show_exception_messages(args, env, fun) do
        try do
            fun.(args, env)
        rescue
            e in Bonbon.Model.Locale.NotFoundError -> { :error, Exception.message(e) }
            e in FunctionClauseError ->
                {
                    :error,
                    case e.module do
                        Bonbon.Model.Locale -> "locale is formatted incorrectly"
                        _ -> Exception.message(e) #todo: replace with friendlier messages
                    end
                }
            e in Postgrex.Error -> { :error, e.postgres[:message] } #todo: replace with friendlier messages
            e -> { :error, Exception.message(e) } #todo: replace with friendlier messages
        end
    end
end
