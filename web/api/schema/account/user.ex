defmodule Bonbon.API.Schema.Account.User do
    use Absinthe.Schema
    @moduledoc false

    @desc "A user account"
    object :user do
        field :id, :id, description: "The id of the user"
        field :name, :string, description: "The name of the user"
        field :email, :string, description: "The email of the user"
        field :mobile, :string, description: "The mobile of the user"
    end

    def register(args, _) do
        case Bonbon.Repo.insert(Bonbon.Model.Account.User.changeset(%Bonbon.Model.Account.User{}, args)) do
            { :error, changeset } -> { :error, [{ :message, "Could not register user account" }|[field_errors: Enum.map(changeset.errors, fn { field, { message, _ } } -> { field, message } end) |> Map.new(&(&1))]] }
            user -> user
        end
    end
end
