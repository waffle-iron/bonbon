defmodule Bonbon.Locale do
    use Bonbon.Web, :model
    @moduledoc """
      A model representing the different languages using culture codes (ISO 3166-1
      alpha-2 and ISO 639-1 code).
    """

    schema "locales" do
        field :country, :string
        field :language, :string

        timestamps()
    end

    @doc """
      Builds a changeset based on the `struct` and `params`.
    """
    def changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [:country, :language])
        |> validate_required(:language)
        |> validate_length(:country, is: 2)
        |> validate_length(:language, is: 2)
        |> format_uppercase(:country)
        |> format_lowercase(:language)
        |> unique_constraint(:culture_code)
    end
end
