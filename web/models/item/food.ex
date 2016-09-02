defmodule Bonbon.Model.Item.Food do
    use Bonbon.Web, :model
    use Translecto.Schema.Translatable
    import Translecto.Changeset
    @moduledoc """
      A model representing the different foods available to order.
    """

    schema "foods" do
        translatable :content, Bonbon.Model.Item.Food.Content.Translation
        field :prep_time, :integer
        field :available, :boolean
        belongs_to :cuisine, Bonbon.Model.Cuisine
        field :calories, :integer
        field :price, :decimal
        field :currency, :string
        field :image, :string
        timestamps
    end

    @doc """
      Builds a changeset based on the `struct` and `params`.
    """
    def changeset(struct, params \\ %{}) do
        struct
        |> translatable_changeset(params, [:content])
        |> cast(params, [:prep_time, :available, :cuisine_id, :calories, :price, :currency, :image])
        |> validate_required([:content, :available, :price, :currency, :image])
        |> validate_length(:currency, is: 3)
        |> format_uppercase(:currency)
        |> assoc_constraint(:cuisine)
        |> unique_constraint(:content)
    end
end
