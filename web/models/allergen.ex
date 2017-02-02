defmodule Bonbon.Model.Allergen do
    use Bonbon.Web, :model
    use Translecto.Schema.Translatable
    import Translecto.Changeset
    @moduledoc """
      A model representing the different food allergens.

      ##Fields

      ###:id
      Is the unique reference to the allergen entry. Is an `integer`.

      ###:name
      Is the name of the allergen. Is a `translatable`.
    """

    schema "allergens" do
        translatable :name, Bonbon.Model.Allergen.Name.Translation
        timestamps
    end

    @doc """
      Builds a changeset based on the `struct` and `params`.

      Enforces:
      * `name` field is translatable
      * `name` field is required
      * `name` field is unique
    """
    def changeset(struct, params \\ %{}) do
        struct
        |> translatable_changeset(params, [:name])
        |> validate_required([:name])
        |> unique_constraint(:name)
    end
end
