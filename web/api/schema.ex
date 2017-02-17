defmodule Bonbon.API.Schema do
    use Absinthe.Schema
    import_types Bonbon.API.Schema.Item.Food
    import_types Bonbon.API.Schema.Account.User
    import_types Bonbon.API.Schema.Account

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
            arg :locale, :string

            @desc "The id of the ingredient"
            arg :id, non_null(:id)

            resolve show_exception_messages(&Bonbon.API.Schema.Ingredient.get/2)
        end

        @desc "Get all the available ingredients"
        field :ingredients, type: list_of(:ingredient) do
            @desc "The locale to return the ingredients in"
            arg :locale, :string

            @desc "The number of ingredients to get"
            arg :limit, :integer, default_value: 50

            @desc "The offset of first ingredient to get"
            arg :offset, :integer, default_value: 0

            @desc "The name to match against"
            arg :name, :string

            @desc "The type to match against"
            arg :type, :string

            @desc "The string to match against (name, type)"
            arg :find, :string

            resolve show_exception_messages(&Bonbon.API.Schema.Ingredient.all/2)
        end

        #cuisine regions
        @desc "Get a culinary region by id"
        field :region, type: :region do
            @desc "The locale to return the region in"
            arg :locale, :string

            @desc "The id of the region"
            arg :id, non_null(:id)

            resolve show_exception_messages(&Bonbon.API.Schema.Cuisine.Region.get/2)
        end

        @desc "Get all the available culinary regions"
        field :regions, type: list_of(:region) do
            @desc "The locale to return the regions in"
            arg :locale, :string

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

        #cuisine
        @desc "Get a cuisine by id"
        field :cuisine, type: :cuisine do
            @desc "The locale to return the cuisine in"
            arg :locale, :string

            @desc "The id of the cuisine"
            arg :id, non_null(:id)

            resolve show_exception_messages(&Bonbon.API.Schema.Cuisine.get/2)
        end

        @desc "Get all the available cuisines"
        field :cuisines, type: list_of(:cuisine) do
            @desc "The locale to return the cuisines in"
            arg :locale, :string

            @desc "The number of cuisines to get"
            arg :limit, :integer, default_value: 50

            @desc "The offset of first cuisine to get"
            arg :offset, :integer, default_value: 0

            @desc "The name to match against"
            arg :name, :string

            @desc "The region to match against"
            arg :region, :region_input

            @desc "The string to match against (name, region)"
            arg :find, :string

            resolve show_exception_messages(&Bonbon.API.Schema.Cuisine.all/2)
        end

        #diet
        @desc "Get an diet by id"
        field :diet, type: :diet do
            @desc "The locale to return the diet in"
            arg :locale, :string

            @desc "The id of the diet"
            arg :id, non_null(:id)

            resolve show_exception_messages(&Bonbon.API.Schema.Diet.get/2)
        end

        @desc "Get all the available diets"
        field :diets, type: list_of(:diet) do
            @desc "The locale to return the diets in"
            arg :locale, :string

            @desc "The number of diets to get"
            arg :limit, :integer, default_value: 50

            @desc "The offset of first diet to get"
            arg :offset, :integer, default_value: 0

            @desc "The name to match against"
            arg :name, :string

            @desc "The string to match against (name)"
            arg :find, :string

            resolve show_exception_messages(&Bonbon.API.Schema.Diet.all/2)
        end

        #allergen
        @desc "Get an allergen by id"
        field :allergen, type: :allergen do
            @desc "The locale to return the allergen in"
            arg :locale, :string

            @desc "The id of the allergen"
            arg :id, non_null(:id)

            resolve show_exception_messages(&Bonbon.API.Schema.Allergen.get/2)
        end

        @desc "Get all the available allergens"
        field :allergens, type: list_of(:allergen) do
            @desc "The locale to return the allergens in"
            arg :locale, :string

            @desc "The number of allergens to get"
            arg :limit, :integer, default_value: 50

            @desc "The offset of first allergen to get"
            arg :offset, :integer, default_value: 0

            @desc "The name to match against"
            arg :name, :string

            @desc "The string to match against (name)"
            arg :find, :string

            resolve show_exception_messages(&Bonbon.API.Schema.Allergen.all/2)
        end

        #food
        @desc "Get a food item by id"
        field :food, type: :food do
            @desc "The locale to return the food in"
            arg :locale, :string

            @desc "The id of the food"
            arg :id, non_null(:id)

            resolve show_exception_messages(&Bonbon.API.Schema.Item.Food.get/2)
        end

        @desc "Get all food items"
        field :foods, type: list_of(:food) do
            @desc "The locale to return the food in"
            arg :locale, :string

            @desc "The number of diets to get"
            arg :limit, :integer, default_value: 50

            @desc "The offset of first diet to get"
            arg :offset, :integer, default_value: 0

            @desc "The name to match against"
            arg :name, :string

            @desc "The cuisines to match against"
            arg :cuisines, list_of(:cuisine_input)

            @desc "The diets to match against"
            arg :diets, list_of(:diet_input)

            @desc "The allergens to not match against"
            arg :allergens, list_of(:allergen_input)

            @desc "The ingredients to match against"
            arg :ingredients, list_of(:ingredient_input)

            @desc "The range of prices to match against"
            arg :prices, list_of(:price_range_input)

            resolve show_exception_messages(&Bonbon.API.Schema.Item.Food.all/2)
        end
    end

    mutation do
        @desc "Register a user account"
        field :register_user, type: :session do
            @desc "The email to use to register the account"
            arg :email, non_null(:string)

            @desc "The password for the account"
            arg :password, non_null(:string)

            @desc "The name of the user"
            arg :name, non_null(:string)

            @desc "The mobile of the user"
            arg :mobile, non_null(:string)

            resolve show_exception_messages(&Bonbon.API.Schema.Account.User.register/2)
        end

        @desc "Login into a user account"
        field :login_user, type: :session do
            @desc "The email of the account"
            arg :email, non_null(:string)

            @desc "The password for the account"
            arg :password, non_null(:string)

            resolve show_exception_messages(&Bonbon.API.Schema.Account.User.login/2)
        end

        @desc "Logout from a user account"
        field :logout_user, type: :session do
            @desc "The active session for an account"
            arg :session, non_null(:session)

            resolve show_exception_messages(&Bonbon.API.Schema.Account.User.logout/2)
        end
    end

    defp show_exception_messages(args, env, fun) do
        try do
            fun.(default_locale(args, env), env)
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
        catch
            :throw, :no_locale -> { :error, "no locale was specified, it must be set either in the argument ('locale:') or as a default locale using the Accept-Language header field" }
        end
    end

    defp default_locale(args, %{ context: %{ locale: locale } }), do: Map.put_new(args, :locale, locale)
    defp default_locale(args = %{ locale: _ }, _), do: args
    defp default_locale(args, %{ definition: %{ schema_node: %{ args: %{ locale: _ } } } }), do: throw :no_locale
    defp default_locale(args, _), do: args
end
