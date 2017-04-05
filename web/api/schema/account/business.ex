defmodule Bonbon.API.Schema.Account.Business do
    use Absinthe.Schema
    @moduledoc false

    @desc "A business account"
    object :business do
        field :id, :id, description: "The id of the business"
        field :name, :string, description: "The name of the business"
        field :email, :string, description: "The email of the business"
        field :mobile, :string, description: "The mobile of the business"
    end

    def register(args, _) do
        with { :ok, business } <- Bonbon.Repo.insert(Bonbon.Model.Account.Business.registration_changeset(%Bonbon.Model.Account.Business{}, args)),
             { :ok, jwt, _ } <- Guardian.encode_and_sign(business) do
                { :ok, %{ token: jwt } }
        else
            { :error, changeset = %Ecto.Changeset{} } -> { :error, [{ :message, "Could not register business account" }|[field_errors: format_changeset_errors(changeset)]] }
            { :error, _ } -> { :error, "Could not create JWT" }
        end
    end

    def login(args, _) do
        case Bonbon.Model.Account.authenticate(Bonbon.Model.Account.Business, args) do
            { :ok, business } ->
                case Guardian.encode_and_sign(business) do
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

    def get(_, %{ context: %{ account: business = %Bonbon.Model.Account.Business{} } }), do: { :ok, business }
    def get(_, _), do: { :error, "No current business account session" }

    def update(args, %{ context: %{ account: business = %Bonbon.Model.Account.Business{} }}) do
        case Bonbon.Repo.update(Bonbon.Model.Account.Business.update_changeset(business, args)) do
            { :error, changeset } -> { :error, [{ :message, "Could not update business account" }|[field_errors: format_changeset_errors(changeset)]] }
            result -> result
        end
    end
    def update(_, _), do: { :error, "No current business account session" }

    defp format_changeset_errors(changeset), do: Enum.map(changeset.errors, fn { field, { message, _ } } -> { field, message } end) |> Map.new(&(&1))
end
