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
    defp build_query(root, fields, args), do: "{ #{to_root(root)}#{to_args(args)}#{to_fields(fields)} }"

    defmacro query(conn, root, fields, args \\ []) do
        quote do
            run(unquote(conn), unquote(build_query(root, fields, args)))
        end
    end

    defmacro query_data(conn, root, fields, args \\ []) do
        quote do
            query(unquote(conn), unquote(root), unquote(fields), unquote(args))["data"][unquote(to_root(root))]
        end
    end

    def get_message(message) do
        [_,message] = String.split(message, ":", parts: 2)
        String.trim(message)
    end

    defmacro query_error(conn, root, fields, args \\ []) do
        quote do
            get_message(List.first(query(unquote(conn), unquote(root), unquote(fields), unquote(args))["errors"])["message"])
        end
    end
end
