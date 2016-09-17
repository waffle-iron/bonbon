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
    end

    defp set_locale(state, []), do: state
    defp set_locale({ :ok, state }, [locale|_]) do
        [lang|_] = String.split(locale, ",", parts: 2)
        [lang|_] = String.split(lang, ";")

        { :ok, %{ locale: String.replace(lang, "-", "_") |> String.trim } } #todo: query the locale ID here instead
    end
    defp set_locale(error, _), do: error
end
