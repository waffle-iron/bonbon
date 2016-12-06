defmodule Bonbon.API.Schema.Price do
    use Absinthe.Schema
    @moduledoc false

    @desc "Price"
    object :price do
        field :amount, :string, description: "The dollar amount"
        field :currency, :string, description: "The currency the price is in"
        field :presentable, :string, description: "The presentable format for the price"
    end

    def format(price, _locale) do
        currency = Currencies.get(price.currency)
        Map.put(price, :presentable, Number.Currency.number_to_currency(price.amount, unit: currency.symbol)) #todo: left/right align unit symbol and use correct delimiter/separator for locale
    end
end
