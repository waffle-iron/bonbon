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

    @doc false
    def to_root(root), do: to_string(root)

    defp format_var([]), do: "[]"
    defp format_var(var) when is_list(var), do: to_args(var) |> String.replace("(", "{ ") |> String.replace(")", " }")
    defp format_var(var) when is_binary(var), do: "\"#{var}\""
    defp format_var(var), do: to_string(var)

    defp to_args([]), do: ""
    defp to_args(args = [arg|_]) do
        args = Enum.map_join(args, ", ", fn
            { name, var } -> "#{to_string(name)}: #{format_var(var)}"
            args -> to_args(args)
        end)
        if(is_list(arg), do: "[#{args}]", else: "(#{args})")
    end

    defp to_fields([]), do: ""
    defp to_fields(fields = [_|_]), do: "{ #{Enum.map_join(fields, " ", &to_fields/1)} }"
    defp to_fields({ name, fields }), do: "#{to_string(name)}#{to_fields(fields)}"
    defp to_fields(field), do: to_string(field)

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
    @spec query(Plug.Conn.t, atom, [atom], keyword(), integer | atom) :: Macro.t
    defmacro query(conn, root, fields, args \\ [], code \\ :ok) do
        quote do
            run(unquote(conn), build_query(unquote(root), unquote(fields), unquote(args)), unquote(code))
        end
    end

    @doc """
      Build and run a GraphQL mutation.

      This macro simplifies constructing GraphQL calls. It then passes them to `run/3`.

      The `conn` argument is the current Plug connection to be used to send the request.

      The `root` argument is the root GraphQL query type.

      The `fields` argument is the GraphQL subfields.

      The `args` argument are the GraphQL mutation arguments.
    """
    @spec mutation(Plug.Conn.t, atom, [atom], keyword(), integer | atom) :: Macro.t
    defmacro mutation(conn, root, fields, args \\ [], code \\ :ok) do
        quote do
            run(unquote(conn), "mutation " <> build_query(unquote(root), unquote(fields), unquote(args)), unquote(code))
        end
    end

    @doc """
      Build and run a GraphQL query.

      The root and subfields are obtained from `@root`, and `@fields`. For more information see
      `query/4`.
    """
    @spec query(Plug.Conn.t, keyword()) :: Macro.t
    defmacro query(conn, args \\ []) do
        quote do
            query(unquote(conn), @root, @fields, unquote(args))
        end
    end

    @doc """
      Build and run a GraphQL mutation.

      The root and subfields are obtained from `@root`, and `@fields`. For more information see
      `mutation/4`.
    """
    @spec mutation(Plug.Conn.t, keyword()) :: Macro.t
    defmacro mutation(conn, args \\ []) do
        quote do
            mutation(unquote(conn), @root, @fields, unquote(args))
        end
    end

    @doc """
      Build and run a GraphQL query, and retrieve the root data.

      This macro simplifies constructing GraphQL calls, and retrieving the root data. For
      more information see: `query/4`
    """
    @spec query_data(Plug.Conn.t, atom, [atom], keyword(), integer | atom) :: Macro.t
    defmacro query_data(conn, root, fields, args \\ [], code \\ :ok) do
        quote do
            query(unquote(conn), unquote(root), unquote(fields), unquote(args), unquote(code))["data"][to_root(unquote(root))]
        end
    end

    @doc """
      Build and run a GraphQL query, and retrieve the root data.

      The root and subfields are obtained from `@root`, and `@fields`. For more information see
      `query_data/4`.
    """
    @spec query_data(Plug.Conn.t, keyword()) :: Macro.t
    defmacro query_data(conn, args \\ []) do
        quote do
            query_data(unquote(conn), @root, @fields, unquote(args))
        end
    end

    @doc """
      Build and run a GraphQL mutation, and retrieve the root data.

      This macro simplifies constructing GraphQL calls, and retrieving the root data. For
      more information see: `mutation/4`
    """
    @spec mutation_data(Plug.Conn.t, atom, [atom], keyword(), integer | atom) :: Macro.t
    defmacro mutation_data(conn, root, fields, args \\ [], code \\ :ok) do
        quote do
            mutation(unquote(conn), unquote(root), unquote(fields), unquote(args), unquote(code))["data"][to_root(unquote(root))]
        end
    end

    @doc """
      Build and run a GraphQL mutation, and retrieve the root data.

      The root and subfields are obtained from `@root`, and `@fields`. For more information see
      `mutation_data/4`.
    """
    @spec mutation_data(Plug.Conn.t, keyword()) :: Macro.t
    defmacro mutation_data(conn, args \\ []) do
        quote do
            mutation_data(unquote(conn), @root, @fields, unquote(args))
        end
    end

    @doc """
      Get the custom portion of the error message.
    """
    @spec get_message(String.t) :: String.t
    def get_message(message) do
        case String.split(message, ":", parts: 2) do
            [_, message] -> message
            [message] -> message
        end |> String.trim
    end

    @doc """
      Build and run a GraphQL query, and retrieve the custom portion of the root error message.

      This macro simplifies constructing GraphQL calls, and retrieving the root error message.
      For more information see: `query/4`
    """
    @spec query_error(Plug.Conn.t, atom, [atom], keyword(), integer | atom) :: Macro.t
    defmacro query_error(conn, root, fields, args \\ [], code \\ :ok) do
        quote do
            get_message(List.first(query(unquote(conn), unquote(root), unquote(fields), unquote(args), unquote(code))["errors"])["message"])
        end
    end

    @doc """
      Build and run a GraphQL query, and retrieve the custom portion of the root error message.

      The root and subfields are obtained from `@root`, and `@fields`. For more information see
      `query_error/4`.
    """
    @spec query_error(Plug.Conn.t, keyword()) :: Macro.t
    defmacro query_error(conn, args \\ []) do
        quote do
            query_error(unquote(conn), @root, @fields, unquote(args))
        end
    end

    @doc """
      Build and run a GraphQL mutation, and retrieve the custom portion of the root error message.

      This macro simplifies constructing GraphQL calls, and retrieving the root error message.
      For more information see: `mutation/4`
    """
    @spec mutation_error(Plug.Conn.t, atom, [atom], keyword(), integer | atom) :: Macro.t
    defmacro mutation_error(conn, root, fields, args \\ [], code \\ :ok) do
        quote do
            get_message(List.first(mutation(unquote(conn), unquote(root), unquote(fields), unquote(args), unquote(code))["errors"])["message"])
        end
    end

    @doc """
      Build and run a GraphQL mutation, and retrieve the custom portion of the root error message.

      The root and subfields are obtained from `@root`, and `@fields`. For more information see
      `mutation_error/4`.
    """
    @spec mutation_error(Plug.Conn.t, keyword()) :: Macro.t
    defmacro mutation_error(conn, args \\ []) do
        quote do
            mutation_error(unquote(conn), @root, @fields, unquote(args))
        end
    end

    @doc false
    def eval_arg_funs(args, db) do
        Enum.map(args, fn
            { name, val } when is_list(val) -> { name, eval_arg_funs(val, db) }
            { name, val } when is_function(val) -> { name, val.(db) }
            arg when is_list(arg) -> eval_arg_funs(arg, db)
            arg -> arg
        end)
    end

    @doc false
    def eval_result(result, locale, db) when is_function(result), do: result.(locale, db)
    def eval_result(result, _, _), do: result

    @doc """
      Test localisation support of GraphQL queries.

      This macro simplifies testing localised GraphQL calls.

      The `message` argument is the message describing the related tests.

      The `result` argument is the expected result to assert against. This takes the form of a function
      accepting the current locale and db, and returns the expected result to test against.

      The `root` argument is the root GraphQL query type.

      The `fields` argument is the GraphQL subfields.

      The `args` argument are the GraphQL query arguments. Any functions may take the form of
      `({ atom, map() } -> { atom, any })` in which they'll be evaluated with the db argument as input, and the
      result is used as the argument in the GraphQL query.
    """
    @spec test_localisable_query(String.t, (:en | :fr, map() -> any), atom, [atom], keyword()) :: Macro.t
    defmacro test_localisable_query(message, result, root, fields, args \\ []) do
        quote do
            describe unquote(message) do
                @tag locale: nil
                test "without locale", %{ conn: conn, db: db } do
                    assert "no locale was specified, it must be set either in the argument ('locale:') or as a default locale using the Accept-Language header field" == query_error(conn, unquote(root), unquote(fields), eval_arg_funs(unquote(args), db))
                end

                @tag locale: "zz"
                test "with invalid locale", %{ conn: conn, db: db } do
                    assert "no locale exists for code: zz" == query_error(conn, unquote(root), unquote(fields), eval_arg_funs(unquote(args), db))
                end

                @tag locale: "en"
                test "in english", %{ conn: conn, db: db } do
                    assert eval_result(unquote(result), :en, db) == query_data(conn, unquote(root), unquote(fields), eval_arg_funs(unquote(args), db))
                end

                @tag locale: "fr"
                test "in french", %{ conn: conn, db: db } do
                    assert eval_result(unquote(result), :fr, db) == query_data(conn, unquote(root), unquote(fields), eval_arg_funs(unquote(args), db))
                end

                @tag locale: "fr"
                test "with overriden locale", %{ conn: conn, db: db } do
                    assert eval_result(unquote(result), :en, db) == query_data(conn, unquote(root), unquote(fields), eval_arg_funs(unquote(Keyword.put(args, :locale, "en")), db))
                end
            end
        end
    end

    @doc """
      Test localisation support of GraphQL queries.

      The root and subfields are obtained from `@root`, and `@fields`. For more information see
      `test_localisable_query/5`.
    """
    @spec test_localisable_query(String.t, (:en | :fr, map() -> any), keyword()) :: Macro.t
    defmacro test_localisable_query(message, result, args \\ []) do
        quote do
            test_localisable_query(unquote(message), unquote(result), @root, @fields, unquote(args))
        end
    end
end
