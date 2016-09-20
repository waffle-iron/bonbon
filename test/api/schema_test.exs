defmodule Bonbon.API.SchemaTest do
    use Bonbon.ConnCase

    setup do
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

        :ok
    end

    test "list all ingredients with invalid locale", %{ conn: conn } do
        conn = conn
            |> put_req_header("content-type", "application/graphql")
            |> put_req_header("accept-language", "zz")
            |> post("/", "{ ingredients { name type } }")

        assert %{
            "data" => %{},
            "errors" => [
                %{
                    "locations" => [%{ "column" => 0, "line" => 1}],
                    "message" => "Field `ingredients': no locale exists for code: zz"
                }
            ]
        } == Poison.decode!(response(conn, :ok))
    end

    test "list all ingredients in english", %{ conn: conn } do
        conn = conn
            |> put_req_header("content-type", "application/graphql")
            |> put_req_header("accept-language", "en")
            |> post("/", "{ ingredients { name type } }")

        assert %{
            "data" => %{
                "ingredients" => [
                    %{ "type" => "fruit", "name" => "apple" },
                    %{ "type" => "fruit", "name" => "lemon" }
                ]
            }
        } == Poison.decode!(response(conn, :ok))
    end

    test "list all ingredients in french", %{ conn: conn } do
        conn = conn
            |> put_req_header("content-type", "application/graphql")
            |> put_req_header("accept-language", "fr")
            |> post("/", "{ ingredients { name type } }")

        assert %{
            "data" => %{
                "ingredients" => [
                    %{ "type" => "fruit", "name" => "pomme" },
                    %{ "type" => "fruit", "name" => "citron" }
                ]
            }
        } == Poison.decode!(response(conn, :ok))
    end

    test "list all ingredients with overriden locale", %{ conn: conn } do
        conn = conn
            |> put_req_header("content-type", "application/graphql")
            |> put_req_header("accept-language", "fr")
            |> post("/", "{ ingredients(locale: en){ name type } }")

        assert %{
            "data" => %{
                "ingredients" => [
                    %{ "type" => "fruit", "name" => "apple" },
                    %{ "type" => "fruit", "name" => "lemon" }
                ]
            }
        } == Poison.decode!(response(conn, :ok))
    end
end
