defmodule Bonbon.LanguageTest do
    use Bonbon.ModelCase

    alias Bonbon.Language

    defp assert_change(model, params \\ %{}) do
        changeset = model.__struct__.changeset(model, params)
        assert changeset.valid?
        changeset
    end

    defp refute_change(model, params \\ %{}) do
        changeset = model.__struct__.changeset(model, params)
        refute changeset.valid?
        changeset
    end

    defp assert_change_value(changeset, field, value) do
        assert value == changeset.changes[field]
        changeset
    end

    defp refute_change_value(changeset, field, value) do
        refute value == changeset.changes[field]
        changeset
    end

    defp assert_error_value(changeset, field, value) do
        assert value == changeset.errors[field]
        changeset
    end

    defp refute_error_value(changeset, field, value) do
        refute value == changeset.errors[field]
        changeset
    end

    defp assert_insert(changeset, result) do
        assert { result, changeset } = Bonbon.Repo.insert(changeset)
        changeset
    end

    defp refute_insert(changeset, result) do
        refute { result, changeset } = Bonbon.Repo.insert(changeset)
        changeset
    end

    @valid_model %Language{ language: "fr", country: "FR" }

    test "empty" do
        refute_change(%Language{})
    end

    test "only language" do
        assert_change(%Language{}, %{ language: "en" })
        |> assert_change_value(:language, "en")
    end

    test "only country" do
        refute_change(%Language{}, %{ country: "AU" })
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

        assert_change(%Language{}, %{ language: @valid_model.language, country: @valid_model.country })
        |> assert_insert(:error)
        |> assert_error_value(:culture_code, { "has already been taken", [] })

        assert_change(%Language{}, %{ language: @valid_model.language })
        |> assert_insert(:ok)

        changeset = assert_change(%Language{}, %{ language: @valid_model.language, country: "GB" })
        |> assert_insert(:ok)

        changeset = assert_change(%Language{}, %{ language: "en", country: @valid_model.country })
        |> assert_insert(:ok)
    end
end
