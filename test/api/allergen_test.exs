defmodule Bonbon.API.AllergenTest do
    use Bonbon.APICase

    setup %{ conn: conn } do
        en = Bonbon.Repo.insert!(%Bonbon.Model.Locale{ language: "en" })
        fr = Bonbon.Repo.insert!(%Bonbon.Model.Locale{ language: "fr" })
        en_peanut = Bonbon.Repo.insert!(Bonbon.Model.Allergen.Name.Translation.changeset(%Bonbon.Model.Allergen.Name.Translation{}, %{ translate_id: 1, locale_id: en.id, term: "peanut allergy" }))
        fr_peanut = Bonbon.Repo.insert!(Bonbon.Model.Allergen.Name.Translation.changeset(%Bonbon.Model.Allergen.Name.Translation{}, %{ translate_id: 1, locale_id: fr.id, term: "allergie à l'arachide" }))
        en_fish = Bonbon.Repo.insert!(Bonbon.Model.Allergen.Name.Translation.changeset(%Bonbon.Model.Allergen.Name.Translation{}, %{ translate_id: 2, locale_id: en.id, term: "fish allergy" }))
        fr_fish = Bonbon.Repo.insert!(Bonbon.Model.Allergen.Name.Translation.changeset(%Bonbon.Model.Allergen.Name.Translation{}, %{ translate_id: 2, locale_id: fr.id, term: "allergie au poisson" }))

        allergen_peanut = Bonbon.Repo.insert!(Bonbon.Model.Allergen.changeset(%Bonbon.Model.Allergen{}, %{ name: en_peanut.translate_id }))
        allergen_fish = Bonbon.Repo.insert!(Bonbon.Model.Allergen.changeset(%Bonbon.Model.Allergen{}, %{ name: en_fish.translate_id }))

        db = %{
            en: %{
                allergen: %{
                    peanut: %{ "id" => to_string(allergen_peanut.id), "name" => en_peanut.term },
                    fish: %{ "id" => to_string(allergen_fish.id), "name" => en_fish.term }
                }
            },
            fr: %{
                allergen: %{
                    peanut: %{ "id" => to_string(allergen_peanut.id), "name" => fr_peanut.term },
                    fish: %{ "id" => to_string(allergen_fish.id), "name" => fr_fish.term }
                }
            }
        }

        { :ok, %{ conn: conn, db: db } }
    end

    #allergen
    @root :allergen
    @fields [:id, :name]

    @tag locale: "en"
    test "get allergen without id", %{ conn: conn } do
        assert nil != query_error(conn, @root, @fields, [], :bad_request) #todo: possibly just check that an error was returned
    end

    #allergen(id:)
    test_localisable_query("get allergen with invalid id", nil, id: 0)

    test_localisable_query("get allergen with id", &(&2[&1].allergen.fish), id: &(&1.en.allergen.fish["id"]))

    @tag locale: "en"
    test "get allergen with non-integer id", %{ conn: conn } do
        assert _ = query_error(conn, id: "test") #todo: change to custom formatted message
    end

    #allergens
    @root :allergens

    test_localisable_query("list all allergens", &([&2[&1].allergen.peanut, &2[&1].allergen.fish]))

    test_localisable_query("list first allergen", &([&2[&1].allergen.peanut]), limit: 1)

    test_localisable_query("list second allergen", &([&2[&1].allergen.fish]), limit: 1, offset: 1)

    @tag locale: "en"
    test "list allergens with negative limit", %{ conn: conn } do
        assert "LIMIT must not be negative" == query_error(conn, limit: -1) #todo: change to custom formatted message
    end

    @tag locale: "en"
    test "list allergens with negative offset", %{ conn: conn } do
        assert "OFFSET must not be negative" == query_error(conn, offset: -1) #todo: change to custom formatted message
    end

    @tag locale: "en"
    test "list allergens with non-integer limit", %{ conn: conn } do
        assert nil != query_error(conn, @root, @fields, [limit: "test"], :bad_request) #todo: possibly just check that an error was returned
    end

    @tag locale: "en"
    test "list allergens with non-integer offset", %{ conn: conn } do
        assert nil != query_error(conn, @root, @fields, [offset: "test"], :bad_request) #todo: possibly just check that an error was returned
    end

    #allergens(name:)
    test_localisable_query("find name 'pea' in allergens", fn
        :en, db -> [db.en.allergen.peanut]
        :fr, _ -> []
    end, name: "pea")

    test_localisable_query("find name 'allergie' in allergens", fn
        :en, _ -> []
        :fr, db -> [db.fr.allergen.peanut, db.fr.allergen.fish]
    end, name: "allergie")

    test_localisable_query("find name 'zz' in allergens", [], name: "zz")

    #allergens(find:)
    test_localisable_query("find 'pea' in allergens", fn
        :en, db -> [db.en.allergen.peanut]
        :fr, _ -> []
    end, find: "pea")

    test_localisable_query("find 'allergie' in allergens", fn
        :en, _ -> []
        :fr, db -> [db.fr.allergen.peanut, db.fr.allergen.fish]
    end, find: "allergie")

    test_localisable_query("find 'zz' in allergens", [], find: "zz")
end
