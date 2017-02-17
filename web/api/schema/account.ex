defmodule Bonbon.API.Schema.Account do
    use Absinthe.Schema
    @moduledoc false

    @desc "An account session"
    object :session do
        field :token, :id, description: "The token representing the active session"
    end
end
