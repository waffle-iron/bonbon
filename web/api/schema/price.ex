defmodule Bonbon.API.Schema.Price do
    use Absinthe.Schema
    @moduledoc false

    @desc "Price"
    object :price do
        field :amount, :string, description: "The dollar amount"
        field :currency, :string, description: "The currency the price is in"
        field :presentable, :string, description: "The presentable format for the price"
    end

    @desc "Price"
    input_object :price_input do
        field :amount, non_null(:string), description: "The dollar amount"
        field :currency, non_null(:string), description: "The currency the price is in"
    end

    @desc "Price range"
    input_object :price_range_input do
        field :min, non_null(:string), description: "The minimum dollar amount"
        field :max, non_null(:string), description: "The maximum dollar amount"
        field :currency, non_null(:string), description: "The currency the price is in"
    end

    def format(price, _locale) do
        currency = Currencies.get(price.currency)
        Map.put(price, :presentable, Number.Currency.number_to_currency(price.amount, unit: currency.symbol)) #todo: left/right align unit symbol and use correct delimiter/separator for locale
    end
end
