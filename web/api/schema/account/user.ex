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
        with { :ok, user } <- Bonbon.Repo.insert(Bonbon.Model.Account.User.changeset(%Bonbon.Model.Account.User{}, args)),
             { :ok, jwt, _ } <- Guardian.encode_and_sign(user) do
                { :ok, %{ token: jwt } }
        else
            { :error, changeset = %Ecto.Changeset{} } -> { :error, [{ :message, "Could not register user account" }|[field_errors: Enum.map(changeset.errors, fn { field, { message, _ } } -> { field, message } end) |> Map.new(&(&1))]] }
            { :error, _ } -> { :error, "Could not create JWT" }
        end
    end

    def login(args, _) do
        case Bonbon.Model.Account.authenticate(Bonbon.Model.Account.User, args) do
            { :ok, user } ->
                case Guardian.encode_and_sign(user) do
                    { :ok, jwt, _ } -> { :ok, %{ token: jwt } }
                    _ -> { :error, "Could not create JWT" }
                end
            error -> error
        end
    end

    def logout(%{ session: %{ token: jwt } }, _) do
        case Guardian.revoke!(jwt) do
            :ok -> { :ok, %{ token: nil } }
            _ -> { :error, "Could not logout of session" }
        end
    end
end
