defmodule Bonbon.GuardianSerializer do
    @behaviour Guardian.Serializer

    def for_token(user = %Bonbon.Model.Account.User{}), do: { :ok, "User:#{user.id}" }
    def for_token(_), do: { :error, "Unknown resource type" }

    def from_token("User:" <> id), do: { :ok, Bonbon.Repo.get(Bonbon.Model.Account.User, id) }
    def from_token(_), do: { :error, "Unknown resource type" }
end
