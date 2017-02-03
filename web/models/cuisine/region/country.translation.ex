defmodule Bonbon.Model.Cuisine.Region.Country.Translation do
    use Bonbon.Web, :model
    use Translecto.Schema.Translation
    @moduledoc """
      A model representing the different country names for the different
      translations.

      ##Fields

      ###:translate_id
      Is the reference to the associated group of region country entries.
      Is an `integer`.

      ###:locale_id
      Is the reference to the specific translations for a given localisation.
      Is an `integer`.

      ###:term
      Is the region country. Is a `string`.
    """

    schema "cuisine_region_country_translations" do
        translation
        field :term, :string
        timestamps
    end

    @doc """
      Builds a changeset based on the `struct` and `params`.

      Enforces:
      * it's a translation
      * `term` field is required
      * formats the `term` field as lowercase
    """
    def changeset(struct, params \\ %{}) do
        struct
        |> translation_changeset(params)
        |> cast(params, [:term])
        |> validate_required([:term])
        |> format_lowercase(:term)
    end
end
