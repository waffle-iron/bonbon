defmodule Bonbon.Model.Ingredient do
    use Bonbon.Web, :model
    use Translecto.Schema.Translatable
    import Translecto.Changeset
    @moduledoc """
      A model representing the different ingredients.

      ##Fields

      ###:id
      Is the unique reference to the ingredient entry. Is an `integer`.

      ###:type
      Is the category type of the ingredient. Is a `translatable`.

      ###:name
      Is the name of the ingredient. Is a `translatable`.
    """

    schema "ingredients" do
        translatable :type, Bonbon.Model.Ingredient.Type.Translation
        translatable :name, Bonbon.Model.Ingredient.Name.Translation
        timestamps
    end

    @doc """
      Builds a changeset based on the `struct` and `params`.

      Enforces:
      * `type` field is translatable
      * `name` field is translatable
      * `name` field is required
      * `name` field is unique
    """
    def changeset(struct, params \\ %{}) do
        struct
        |> translatable_changeset(params, [:type, :name])
        |> validate_required([:name])
        |> unique_constraint(:name)
    end
end
