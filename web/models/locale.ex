defmodule Bonbon.Model.Locale do
    use Bonbon.Web, :model
    @moduledoc """
      A model representing the different languages using culture codes (ISO 3166-1
      alpha-2 and ISO 639-1 code).
    """

    defmodule NotFoundError do
        @moduledoc """
          Exception raised when a locale does not exist.
        """
        defexception [:message, :code]

        def exception(option), do: %Bonbon.Model.Locale.NotFoundError{ message: "no locale exists for code: #{option[:code]}", code: option[:code] }
    end

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
      Get the locale_id for the given string or raise the exception
      `Bonbon.Model.Locale.NotFoundError` on an invalid locale. For more details
      see: `to_locale_id/1`.
    """
    @spec to_locale_id!(String.t) :: integer
    def to_locale_id!(code) do
        case to_locale_id(code) do
            nil -> raise(Bonbon.Model.Locale.NotFoundError, code: code)
            locale -> locale
        end
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

    @doc """
      Get the fallback list of locale_id's for the given string or raise the exception
      `Bonbon.Model.Locale.NotFoundError` when no locales are found. For more details
      see: `to_locale_id_list/1`.
    """
    @spec to_locale_id!(String.t) :: [integer]
    def to_locale_id_list!(code) do
        case to_locale_id_list(code) do
            [] -> raise(Bonbon.Model.Locale.NotFoundError, code: code)
            locale -> locale
        end
    end

    @doc """
      Get the fallback list of locale_id's for the given string or empty list if no
      locales were valid.

      The string format takes the form of `language_country` or `language` when no
      country is specified. e.g. `"en"` and `"en_AU"` would be valid formats, the
      first referring to the english locale, the second referring to Australian
      english.

      This list includes the top-most locale, and parent locales (to fallback to).
    """
    @spec to_locale_id_list(String.t) :: [integer] | nil
    def to_locale_id_list(<<language :: binary-size(2), "_", country :: binary-size(2)>>), do: [to_locale_id(language, country), to_locale_id(language, nil)] |> Enum.filter(&(&1 != nil))
    def to_locale_id_list(<<language :: binary-size(2)>>), do: [to_locale_id(language, nil)] |> Enum.filter(&(&1 != nil))

    defp to_locale_id(language, nil) do
        query = from locale in Bonbon.Model.Locale,
            where: locale.language == ^String.downcase(language) and is_nil(locale.country),
            select: locale.id

        Bonbon.Repo.one(query)
    end
    defp to_locale_id(language, country) do
        query = from locale in Bonbon.Model.Locale,
            where: locale.language == ^String.downcase(language) and locale.country == ^String.upcase(country),
            select: locale.id

        Bonbon.Repo.one(query)
    end
end
