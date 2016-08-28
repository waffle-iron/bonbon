defmodule Bonbon.TranslationCase do
    @moduledoc """
      This module defines the test case to be used by
      translation model tests.
    """

    use ExUnit.CaseTemplate

    using(options) do
        options = Keyword.merge([
            model: to_string(__CALLER__.module) |> String.trim_trailing("Test") |> String.to_atom,
            field: [term: [type: :string, optional: false, case: :lowercase]] #type: [:string], optional: [true, false], case: [:lowercase, :uppercase, nil]
        ], options)

        fields = Enum.reduce(options[:field], %{}, fn { field, attributes }, acc ->
            Map.put(acc, field, case attributes[:type] do
                :string -> "lemon"
            end)
        end)

        alt_fields = Enum.reduce(options[:field], %{}, fn { field, attributes }, acc ->
            Map.put(acc, field, case attributes[:type] do
                :string -> "orange"
            end)
        end)

        quote do
            import Bonbon.TranslationCase
            use Bonbon.ModelCase

            alias unquote(options[:model])

            @pkey String.to_atom(unquote(options[:model]).__schema__(:source) <> "_pkey")
            @valid_model Map.merge(%Translation{ locale_id: 1 }, unquote(Macro.escape(fields)))

            test "empty" do
                refute_change(%Translation{})
            end

            test "only locale" do
                refute_change(%Translation{}, %{ locale_id: 1 })
            end

            test "only translate" do
                refute_change(%Translation{}, %{ translate_id: 1 })
            end

            for { field, value } <- Map.to_list(unquote(Macro.escape(fields))) do
                @tag [field: field, value: value]
                test "only #{field}", %{ field: field, value: value } do
                    refute_change(%Translation{}, %{ field => value })
                end
            end

            test "without locale" do
                refute_change(%Translation{}, Map.merge(%{ translate_id: 1 }, unquote(Macro.escape(fields))))
            end

            test "without translate" do
                changeset = assert_change(%Translation{}, Map.merge(%{ locale_id: 1 }, unquote(Macro.escape(fields))))
                |> assert_change_value(:locale_id, 1)

                for { field, value } <- Map.to_list(unquote(Macro.escape(fields))) do
                    assert_change_value(changeset, field, value)
                end
            end

            for { field, value } <- Map.to_list(unquote(Macro.escape(fields))) do
                @tag [field: field, value: value]
                test "without #{field}", %{ field: field, value: value } do
                    if unquote(options[:field])[field][:optional] do
                        assert_change(%Translation{}, Map.merge(%{ locale_id: 1, translate_id: 1 }, Map.delete(unquote(Macro.escape(fields)), field)))
                    else
                        refute_change(%Translation{}, Map.merge(%{ locale_id: 1, translate_id: 1 }, Map.delete(unquote(Macro.escape(fields)), field)))
                    end
                end
            end

            for { field, attributes } <- unquote(options[:field]), attributes[:type] == :string do
                casing = attributes[:case]
                if casing do
                    formatter = case casing do
                        :lowercase -> &String.downcase/1
                        :uppercase -> &String.upcase/1
                    end

                    @tag [field: field, formatter: formatter]
                    test "#{field} casing", %{ field: field, formatter: formatter } do
                        assert_change(@valid_model, %{ field => "orange" }) |> assert_change_value(field, formatter.("orange"))
                        assert_change(@valid_model, %{ field => "Orange" }) |> assert_change_value(field, formatter.("orange"))
                        assert_change(@valid_model, %{ field => "orangE" }) |> assert_change_value(field, formatter.("orange"))
                        assert_change(@valid_model, %{ field => "ORANGE" }) |> assert_change_value(field, formatter.("orange"))
                    end
                end
            end

            test "uniqueness" do
                en = Bonbon.Repo.insert!(%Bonbon.Model.Locale{ language: "en" })
                fr = Bonbon.Repo.insert!(%Bonbon.Model.Locale{ language: "fr" })
                name = Bonbon.Repo.insert!(Translation.changeset(@valid_model, %{ locale_id: en.id }))

                assert_change(%Translation{}, Map.merge(%{ locale_id: fr.id + 1 }, unquote(Macro.escape(alt_fields))))
                |> assert_insert(:error)
                |> assert_error_value(:locale, { "does not exist", [] })

                assert_change(%Translation{}, Map.merge(%{ locale_id: en.id, translate_id: name.translate_id }, unquote(Macro.escape(alt_fields))))
                |> assert_insert(:error)
                |> assert_error_value(@pkey, { "has already been taken", [] })

                assert_change(%Translation{}, Map.merge(%{ locale_id: fr.id, translate_id: name.translate_id }, unquote(Macro.escape(alt_fields))))
                |> assert_insert(:ok)

                assert_change(%Translation{}, Map.merge(%{ locale_id: en.id }, unquote(Macro.escape(alt_fields))))
                |> assert_insert(:ok)
            end
        end
    end
end
