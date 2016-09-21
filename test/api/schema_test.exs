defmodule Bonbon.API.SchemaTest do
    use Bonbon.ConnCase

    setup %{ conn: conn, locale: locale } do
        en = Bonbon.Repo.insert!(%Bonbon.Model.Locale{ language: "en" })
        fr = Bonbon.Repo.insert!(%Bonbon.Model.Locale{ language: "fr" })
        en_fruit = Bonbon.Repo.insert!(%Bonbon.Model.Ingredient.Type.Translation{ translate_id: 1, locale_id: en.id, term: "fruit" })
        fr_fruit = Bonbon.Repo.insert!(%Bonbon.Model.Ingredient.Type.Translation{ translate_id: 1, locale_id: fr.id, term: "fruit" })
        en_apple = Bonbon.Repo.insert!(%Bonbon.Model.Ingredient.Name.Translation{ translate_id: 1, locale_id: en.id, term: "apple" })
        fr_apple = Bonbon.Repo.insert!(%Bonbon.Model.Ingredient.Name.Translation{ translate_id: 1, locale_id: fr.id, term: "pomme" })
        en_lemon = Bonbon.Repo.insert!(%Bonbon.Model.Ingredient.Name.Translation{ translate_id: 2, locale_id: en.id, term: "lemon" })
        fr_lemon = Bonbon.Repo.insert!(%Bonbon.Model.Ingredient.Name.Translation{ translate_id: 2, locale_id: fr.id, term: "citron" })

        ingredient_apple = Bonbon.Repo.insert!(%Bonbon.Model.Ingredient{ type: en_fruit.translate_id, name: en_apple.translate_id })
        ingredient_lemon = Bonbon.Repo.insert!(%Bonbon.Model.Ingredient{ type: en_fruit.translate_id, name: en_lemon.translate_id })

        conn = put_req_header(conn, "content-type", "application/graphql")
        conn = if locale do
            put_req_header(conn, "accept-language", locale)
        else
            delete_req_header(conn, "accept-language")
        end

        { :ok, %{ conn: conn } }
    end

    defp run(conn, query, code \\ :ok), do: Poison.decode!(response(post(conn, "/", query), code))

    @tag locale: nil
    test "list all ingredients without locale", %{ conn: conn } do
        assert %{
            "data" => %{},
            "errors" => [
                %{
                    "locations" => [%{ "column" => 0, "line" => 1}],
                    "message" => "Field `ingredients': no locale was specified, it must be set either in the argument ('locale:') or as a default locale using the Accept-Language header field"
                }
            ]
        } == run(conn, "{ ingredients { name type } }")
    end

    @tag locale: "zz"
    test "list all ingredients with invalid locale", %{ conn: conn } do
        assert %{
            "data" => %{},
            "errors" => [
                %{
                    "locations" => [%{ "column" => 0, "line" => 1}],
                    "message" => "Field `ingredients': no locale exists for code: zz"
                }
            ]
        } == run(conn, "{ ingredients { name type } }")
    end

    @tag locale: "en"
    test "list all ingredients in english", %{ conn: conn } do
        assert %{
            "data" => %{
                "ingredients" => [
                    %{ "type" => "fruit", "name" => "apple" },
                    %{ "type" => "fruit", "name" => "lemon" }
                ]
            }
        } == run(conn, "{ ingredients { name type } }")
    end

    @tag locale: "fr"
    test "list all ingredients in french", %{ conn: conn } do
        assert %{
            "data" => %{
                "ingredients" => [
                    %{ "type" => "fruit", "name" => "pomme" },
                    %{ "type" => "fruit", "name" => "citron" }
                ]
            }
        } == run(conn, "{ ingredients { name type } }")
    end

    @tag locale: "fr"
    test "list all ingredients with overriden locale", %{ conn: conn } do
        assert %{
            "data" => %{
                "ingredients" => [
                    %{ "type" => "fruit", "name" => "apple" },
                    %{ "type" => "fruit", "name" => "lemon" }
                ]
            }
        } == run(conn, "{ ingredients(locale: en){ name type } }")
    end
end
