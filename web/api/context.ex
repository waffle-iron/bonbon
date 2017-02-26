defmodule Bonbon.API.Context do
    @behaviour Plug

    def init(opts), do: opts

    def call(conn, _opts) do
        case build_context(conn) do
            { :ok, context} -> Plug.Conn.put_private(conn, :absinthe, %{ context: context })
            { :error, reason } -> Plug.Conn.send_resp(conn, 403, reason)
            _ -> Plug.Conn.send_resp(conn, 400, "Bad Request")
        end
    end

    defp build_context(conn) do
        { :ok, %{} }
        |> set_locale(Plug.Conn.get_req_header(conn, "accept-language"))
        |> set_account(Plug.Conn.get_req_header(conn, "authorization"))
    end

    defp set_locale(state, []), do: state
    defp set_locale({ :ok, state }, [locale|_]) do
        [lang|_] = String.split(locale, ",", parts: 2)
        [lang|_] = String.split(lang, ";")

        { :ok, Map.put(state, :locale, String.replace(lang, "-", "_") |> String.trim) }
    end
    defp set_locale(error, _), do: error

    defp set_account(state, []), do: state
    defp set_account({ :ok, state }, ["Bearer " <> token|_]) do
        with { :ok, %{ "sub" => sub } } <- Guardian.decode_and_verify(token),
             { :ok, account } <- Guardian.serializer.from_token(sub) do
                { :ok, Map.put(state, :account, account) }
        else
            _ -> { :ok, state }
        end
    end
    defp set_account(error, _), do: error
end
