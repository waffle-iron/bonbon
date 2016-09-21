defmodule Bonbon.APICase do
    @moduledoc """
      This module defines the test case to be used by
      GraphQL endpoint tests.
    """

    use ExUnit.CaseTemplate
    use Phoenix.ConnTest

    using do
        quote do
            import Bonbon.APICase
            use Phoenix.ConnTest

            alias Bonbon.Repo
            import Ecto
            import Ecto.Changeset
            import Ecto.Query

            # The default endpoint for testing
            @endpoint Bonbon.Endpoint
        end
    end

    setup tags do
        :ok = Ecto.Adapters.SQL.Sandbox.checkout(Bonbon.Repo)

        unless tags[:async] do
            Ecto.Adapters.SQL.Sandbox.mode(Bonbon.Repo, { :shared, self() })
        end

        conn = build_conn()
            |> put_req_header("content-type", "application/graphql")

        conn = if tags[:locale] do
            put_req_header(conn, "accept-language", tags[:locale])
        else
            delete_req_header(conn, "accept-language")
        end

        { :ok, conn: conn }
    end

    defmacro run(conn, query, code \\ :ok) do
        quote do
            Poison.decode!(response(post(unquote(conn), "/", unquote(query)), unquote(code)))
        end
    end
end
