defmodule Bonbon.API.SchemaTest do
    use Bonbon.APICase

    setup %{ conn: conn } do
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

        db = %{
            en: %{
                ingredient: %{
                    apple: %{ "id" => to_string(ingredient_apple.id), "type" => en_fruit.term, "name" => en_apple.term },
                    lemon: %{ "id" => to_string(ingredient_lemon.id), "type" => en_fruit.term, "name" => en_lemon.term }
                }
            },
            fr: %{
                ingredient: %{
                    apple: %{ "id" => to_string(ingredient_apple.id), "type" => fr_fruit.term, "name" => fr_apple.term },
                    lemon: %{ "id" => to_string(ingredient_lemon.id), "type" => fr_fruit.term, "name" => fr_lemon.term }
                }
            }
        }

        { :ok, %{ conn: conn, db: db } }
    end

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
        } == run(conn, "{ ingredients { id name type } }")
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
        } == run(conn, "{ ingredients { id name type } }")
    end

    @tag locale: "en"
    test "list all ingredients in english", %{ conn: conn, db: db } do
        assert %{
            "data" => %{
                "ingredients" => [
                    db.en.ingredient.apple,
                    db.en.ingredient.lemon
                ]
            }
        } == run(conn, "{ ingredients { id name type } }")
    end

    @tag locale: "fr"
    test "list all ingredients in french", %{ conn: conn, db: db } do
        assert %{
            "data" => %{
                "ingredients" => [
                    db.fr.ingredient.apple,
                    db.fr.ingredient.lemon
                ]
            }
        } == run(conn, "{ ingredients { id name type } }")
    end

    @tag locale: "fr"
    test "list all ingredients with overriden locale", %{ conn: conn, db: db } do
        assert %{
            "data" => %{
                "ingredients" => [
                    db.en.ingredient.apple,
                    db.en.ingredient.lemon
                ]
            }
        } == run(conn, "{ ingredients(locale: en){ id name type } }")
    end
end