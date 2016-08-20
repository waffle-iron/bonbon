defmodule Bonbon.IngredientTypeTranslation do
    use Bonbon.Web, :model
    use Translecto.Schema
    @moduledoc """
      A model representing the different ingredient types for the different
      translations.
    """

    schema "ingredient_type_translations" do
        translation
        field :term, :string
        timestamps
    end

    @doc """
      Builds a changeset based on the `struct` and `params`.
    """
    def changeset(struct, params \\ %{}) do
        struct
        |> translation_changeset(params)
        |> cast(params, [:term])
        |> validate_required([:term])
        |> format_lowercase(:term)
    end
end
