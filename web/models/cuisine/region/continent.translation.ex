defmodule Bonbon.Cuisine.Region.Continent.Translation do
    use Bonbon.Web, :model
    use Translecto.Schema.Translation
    @moduledoc """
      A model representing the different continent names for the different
      translations.
    """

    schema "cuisine_region_continent_translations" do
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
