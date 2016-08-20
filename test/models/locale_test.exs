defmodule Bonbon.LocaleTest do
    use Bonbon.ModelCase

    alias Bonbon.Locale

    @valid_model %Locale{ language: "fr", country: "FR" }

    test "empty" do
        refute_change(%Locale{})
    end

    test "only language" do
        assert_change(%Locale{}, %{ language: "en" })
        |> assert_change_value(:language, "en")
    end

    test "only country" do
        refute_change(%Locale{}, %{ country: "AU" })
        |> assert_change_value(:country, "AU")
    end

    test "language length" do
        refute_change(@valid_model, %{ language: "" })
        refute_change(@valid_model, %{ language: "e" })
        assert_change(@valid_model, %{ language: "en" }) |> assert_change_value(:language, "en")
        refute_change(@valid_model, %{ language: "eng" })
    end

    test "country length" do
        assert_change(@valid_model, %{ country: "" }) |> assert_change_value(:country, nil)
        refute_change(@valid_model, %{ country: "A" })
        assert_change(@valid_model, %{ country: "AU" }) |> assert_change_value(:country, "AU")
        refute_change(@valid_model, %{ country: "AUS" })
    end

    test "language casing" do
        assert_change(@valid_model, %{ language: "en" }) |> assert_change_value(:language, "en")
        assert_change(@valid_model, %{ language: "En" }) |> assert_change_value(:language, "en")
        assert_change(@valid_model, %{ language: "eN" }) |> assert_change_value(:language, "en")
        assert_change(@valid_model, %{ language: "EN" }) |> assert_change_value(:language, "en")
    end

    test "country casing" do
        assert_change(@valid_model, %{ country: "AU" }) |> assert_change_value(:country, "AU")
        assert_change(@valid_model, %{ country: "aU" }) |> assert_change_value(:country, "AU")
        assert_change(@valid_model, %{ country: "Au" }) |> assert_change_value(:country, "AU")
        assert_change(@valid_model, %{ country: "au" }) |> assert_change_value(:country, "AU")
    end

    test "uniqueness" do
        Bonbon.Repo.insert!(@valid_model)

        assert_change(%Locale{}, %{ language: @valid_model.language, country: @valid_model.country })
        |> assert_insert(:error)
        |> assert_error_value(:culture_code, { "has already been taken", [] })

        assert_change(%Locale{}, %{ language: @valid_model.language })
        |> assert_insert(:ok)

        changeset = assert_change(%Locale{}, %{ language: @valid_model.language, country: "GB" })
        |> assert_insert(:ok)

        changeset = assert_change(%Locale{}, %{ language: "en", country: @valid_model.country })
        |> assert_insert(:ok)
    end
end
