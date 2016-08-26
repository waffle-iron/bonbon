defmodule Bonbon.Model.Cuisine.Region.Province.Translation do
    use Bonbon.Web, :model
    use Translecto.Schema.Translation
    @moduledoc """
      A model representing the different province names for the different
      translations.
    """

    schema "cuisine_region_province_translations" do
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
