defmodule Bonbon.ChangesetHelpers do
    @moduledoc """
      Common helper functions for filtering and validation of Ecto Changeset's.
    """

    @doc """
      Change the given string field to lowercase.
    """
    @spec format_lowercase(Ecto.Changeset.t, atom) :: Ecto.Changeset.t
    def format_lowercase(changeset, field) do
        case changeset do
            %Ecto.Changeset{ valid?: true, changes: %{ ^field => value } } when is_binary(value) -> Ecto.Changeset.put_change(changeset, field, String.downcase(value))
            _ -> changeset
        end
    end

    @doc """
      Change the given string field to uppercase.
    """
    @spec format_uppercase(Ecto.Changeset.t, atom) :: Ecto.Changeset.t
    def format_uppercase(changeset, field) do
        case changeset do
            %Ecto.Changeset{ valid?: true, changes: %{ ^field => value } } when is_binary(value) -> Ecto.Changeset.put_change(changeset, field, String.upcase(value))
            _ -> changeset
        end
    end

    @doc """
      Hash the given string field, and pass it into the field name followed by
      `_hash`.
    """
    @spec format_hash(Ecto.Changeset.t, atom) :: Ecto.Changeset.t
    def format_hash(changeset, field), do: format_hash(changeset, field, String.to_atom(to_string(field) <> "_hash"))

    @doc """
      Hash the given string field, and pass it into the hash_field.
    """
    @spec format_hash(Ecto.Changeset.t, atom, atom) :: Ecto.Changeset.t
    def format_hash(changeset, field, hash_field) do
        case changeset do
            %Ecto.Changeset{ valid?: true, changes: %{ ^field => value } } when is_binary(value) -> Ecto.Changeset.put_change(changeset, hash_field, Comeonin.Bcrypt.hashpwsalt(value))
            _ -> changeset
        end
    end
end
