defmodule Translecto.Changeset do
    import Ecto.Changeset
    @moduledoc """
      Convenient changesets to perform validation and casting of translation fields.
    """

    @type changeset :: Ecto.Schema.t | Ecto.Changeset.t | { Ecto.Changeset.data, Ecto.Changeset.types }

    @doc """
      Validate and cast a translation model.
    """
    @spec translation_changeset(changeset, %{}, keyword()) :: changeset
    def translation_changeset(struct, params, opts \\ []) do
        pkey = String.to_atom(Ecto.get_meta(struct, :source) <> "_pkey")

        struct
        |> cast(params, [:translate_id, :locale_id])
        |> validate_required([:locale_id])
        |> assoc_constraint(:locale)
        |> unique_constraint(pkey, name: pkey) #todo: don't handle when primary_key is set to false
    end

    @doc """
      Validate and cast a translatable field.
    """
    @spec translatable_changeset(changeset, %{}, [String.t | atom], keyword()) :: changeset
    def translatable_changeset(struct, params, allowed, opts \\ []) do
        struct
        |> cast(params, allowed)
    end
end
