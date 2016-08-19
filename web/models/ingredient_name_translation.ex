defmodule Bonbon.IngredientNameTranslation do
    use Bonbon.Web, :model
    @moduledoc """
      A model representing the different ingredient names for the different
      translations.
    """

    @primary_key { :translate_id, :id, autogenerate: true }
    schema "ingredient_name_translations" do
        belongs_to :locale, Bonbon.Locale
        field :term, :string

        timestamps()
    end

    @doc """
      Builds a changeset based on the `struct` and `params`.
    """
    def changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [:translate_id, :locale_id, :term])
        |> validate_required([:locale_id, :term])
        |> assoc_constraint(:locale)
        |> unique_constraint(:ingredient_name_translations_pkey, name: :ingredient_name_translations_pkey)
        |> format_lowercase(:term)
    end
end
