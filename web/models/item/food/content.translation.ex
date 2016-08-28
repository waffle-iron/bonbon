defmodule Bonbon.Model.Item.Food.Content.Translation do
    use Bonbon.Web, :model
    use Translecto.Schema.Translation
    @moduledoc """
      A model representing the different food content for the different
      translations.
    """

    schema "food_content_translations" do
        translation
        field :name, :string
        field :description, :string
        timestamps
    end

    @doc """
      Builds a changeset based on the `struct` and `params`.
    """
    def changeset(struct, params \\ %{}) do
        struct
        |> translation_changeset(params)
        |> cast(params, [:name, :description])
        |> validate_required([:name, :description])
    end
end
