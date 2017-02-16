defmodule Bonbon.Model.Account do
    @moduledoc """
        Handles authentication of accounts.
    """

    #todo: possibly change it to a protocol if supporting multiple authentication
    #      types and could return a generic account interface (for the user, business,
    #      manager, etc. accounts).

    @doc """
      Authenticate a given login.

      Returning `{ :ok, account }` if authentication was successful, otherwise
      `{ :error, message }` on failure.

      ##Example

        authenticate(Bonbon.Model.Account.User, email: "foo@bar", password: "test")
    """
    @spec authenticate(Ecto.Queryable.t, Keyword.t) :: { :ok, Ecto.Schema.t } | { :error, String.t }
    def authenticate(model, params \\ []) do
        account = Bonbon.Repo.get_by(model, email: params[:email])
        case match(account, params) do
            true -> { :ok, account }
            false -> { :error, "Invalid credentials" }
        end
    end

    @doc """
      Authenticate a given login.

      Returning `account` if authentication was successful, otherwise raising the
      exception `Bonbon.Model.Account.AuthenticationError` on failure.
    """
    @spec authenticate!(Ecto.Queryable.t, Keyword.t) :: Ecto.Schema.t | no_return
    def authenticate!(model, params \\ []) do
        case authenticate(model, params) do
            { :ok, account } -> account
            { :error, _ } -> raise Bonbon.Model.Account.AuthenticationError
        end
    end

    @spec match(Ecto.Schema.t, Keyword.t) :: boolean()
    defp match(nil, _), do: false
    defp match(account, params), do: Comeonin.Bcrypt.checkpw(params[:password], account.password_hash)

    defmodule AuthenticationError do
        @moduledoc """
          Exception raised when account authentication fails.
        """
        defexception [:message]

        def exception(_), do: %Bonbon.Model.Account.AuthenticationError{ message: "Invalid credentials" }
    end
end
