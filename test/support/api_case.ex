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

    @doc """
      Submit a GraphQL query and retrieve the result.

      This macro simplifies running GraphQL calls by handling the submission, response,
      and converting the JSON result to an Elixir Map.

      The `conn` argument is the current Plug connection to be used to send the request.

      The `query` argument is the GraphQL query itself.

      The `code` argument is the status code returned. See `[Plug.Conn.Status](https://hexdocs.pm/plug/Plug.Conn.Status.html)`
    """
    @spec run(Plug.Conn.t, String.t, integer | atom) :: Macro.t
    defmacro run(conn, query, code \\ :ok) do
        quote do
            Poison.decode!(response(post(unquote(conn), "/", unquote(query)), unquote(code)))
        end
    end

    defp to_root(root), do: to_string(root)

    defp to_args([]), do: ""
    defp to_args(args) do
        args = Enum.map_join(args, ", ", fn { name, var } ->
            "#{to_string(name)}: #{to_string(var)}"
        end)
        "(#{args})"
    end

    defp to_fields([]), do: ""
    defp to_fields(fields), do: "{ #{Enum.map_join(fields, " ", &to_string/1)} }"

    #todo: need to add support for more elaborate queries
    def build_query(root, fields, args), do: "{ #{to_root(root)}#{to_args(args)}#{to_fields(fields)} }"

    @doc """
      Build and run a GraphQL query.

      This macro simplifies constructing GraphQL calls. It then passes them to `run/3`.

      The `conn` argument is the current Plug connection to be used to send the request.

      The `root` argument is the root GraphQL query type.

      The `fields` argument is the GraphQL subfields.

      The `args` argument are the GraphQL query arguments.
    """
    @spec query(Plug.Conn.t, atom, [atom], keyword()) :: Macro.t
    defmacro query(conn, root, fields, args \\ []) do
        quote do
            run(unquote(conn), build_query(unquote(root), unquote(fields), unquote(args)))
        end
    end

    @doc """
      Build and run a GraphQL query, and retrieve the root data.

      This macro simplifies constructing GraphQL calls, and retrieving the root data. For
      more information see: `query/4`
    """
    @spec query_data(Plug.Conn.t, atom, [atom], keyword()) :: Macro.t
    defmacro query_data(conn, root, fields, args \\ []) do
        quote do
            query(unquote(conn), unquote(root), unquote(fields), unquote(args))["data"][unquote(to_root(root))]
        end
    end

    @doc """
      Get the custom portion of the error message.
    """
    @spec get_message(String.t) :: String.t
    def get_message(message) do
        [_,message] = String.split(message, ":", parts: 2)
        String.trim(message)
    end

    @doc """
      Build and run a GraphQL query, and retrieve the custom portion of the root error message.

      This macro simplifies constructing GraphQL calls, and retrieving the root error message.
      For more information see: `query/4`
    """
    @spec query_error(Plug.Conn.t, atom, [atom], keyword()) :: Macro.t
    defmacro query_error(conn, root, fields, args \\ []) do
        quote do
            get_message(List.first(query(unquote(conn), unquote(root), unquote(fields), unquote(args))["errors"])["message"])
        end
    end
end
