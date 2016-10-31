defmodule Bonbon.API.Schema.Price do
    use Absinthe.Schema
    @moduledoc false

    @desc "Price"
    object :price do
        field :amount, :string, description: "The dollar amount"
        field :currency, :string, description: "The currency the price is in"
        field :presentable, :string, description: "The presentable format for the price"
    end
end
