defmodule Bonbon.Model.Locale do
    use Bonbon.Web, :model
    @moduledoc """
      A model representing the different languages using culture codes (ISO 3166-1
      alpha-2 and ISO 639-1 code).
    """

    schema "locales" do
        field :country, :string
        field :language, :string
        timestamps
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

    @doc """
      Get the locale_id for the given string or nil on an invalid locale.

      The string format takes the form of `language_country` or `language` when no
      country is specified. e.g. `"en"` and `"en_AU"` would be valid formats, the
      first referring to the english locale, the second referring to Australian
      english.
    """
    @spec to_locale_id(String.t) :: integer | nil
    def to_locale_id(<<language :: binary-size(2), "_", country :: binary-size(2)>>), do: to_locale_id(language, country)
    def to_locale_id(<<language :: binary-size(2)>>), do: to_locale_id(language, nil)

    defp to_locale_id(language, nil) do
        query = from locale in Bonbon.Model.Locale,
            where: locale.language == ^language and is_nil(locale.country),
            select: locale.id

        Bonbon.Repo.one(query)
    end
    defp to_locale_id(language, country) do
        query = from locale in Bonbon.Model.Locale,
            where: locale.language == ^language and locale.country == ^country,
            select: locale.id

        Bonbon.Repo.one(query)
    end
end
