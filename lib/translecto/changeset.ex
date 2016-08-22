defmodule Translecto.Changeset do
    import Ecto.Changeset

    def translation_changeset(struct, params, opts \\ []) do
        pkey = String.to_atom(Ecto.get_meta(struct, :source) <> "_pkey")

        struct
        |> cast(params, [:translate_id, :locale_id])
        |> validate_required([:locale_id])
        |> assoc_constraint(:locale)
        |> unique_constraint(pkey, name: pkey) #todo: don't handle when primary_key is set to false
    end

    def translatable_changeset(struct, params, allowed, opts \\ []) do
        struct
        |> cast(params, allowed)
    end
end
