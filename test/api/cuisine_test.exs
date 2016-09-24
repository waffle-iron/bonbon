defmodule Bonbon.API.CuisineTest do
    use Bonbon.APICase

    setup %{ conn: conn } do
        en = Bonbon.Repo.insert!(%Bonbon.Model.Locale{ language: "en" })
        fr = Bonbon.Repo.insert!(%Bonbon.Model.Locale{ language: "fr" })

        en_continent_oceania = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.Continent.Translation.changeset(%Bonbon.Model.Cuisine.Region.Continent.Translation{}, %{ translate_id: 1, locale_id: en.id, term: "oceanic" }))
        fr_continent_oceania = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.Continent.Translation.changeset(%Bonbon.Model.Cuisine.Region.Continent.Translation{}, %{ translate_id: 1, locale_id: fr.id, term: "océanique" }))
        en_subregion_australasia = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.Subregion.Translation.changeset(%Bonbon.Model.Cuisine.Region.Subregion.Translation{}, %{ translate_id: 1, locale_id: en.id, term: "australasian" }))
        fr_subregion_australasia = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.Subregion.Translation.changeset(%Bonbon.Model.Cuisine.Region.Subregion.Translation{}, %{ translate_id: 1, locale_id: fr.id, term: "australasian" }))
        en_country_australia = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.Country.Translation.changeset(%Bonbon.Model.Cuisine.Region.Country.Translation{}, %{ translate_id: 1, locale_id: en.id, term: "australia" }))
        fr_country_australia = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.Country.Translation.changeset(%Bonbon.Model.Cuisine.Region.Country.Translation{}, %{ translate_id: 1, locale_id: fr.id, term: "australie" }))
        en_province_brisbane = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.Province.Translation.changeset(%Bonbon.Model.Cuisine.Region.Province.Translation{}, %{ translate_id: 1, locale_id: en.id, term: "brisbane" }))
        fr_province_brisbane = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.Province.Translation.changeset(%Bonbon.Model.Cuisine.Region.Province.Translation{}, %{ translate_id: 1, locale_id: fr.id, term: "brisbane" }))

        en_continent_europe = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.Continent.Translation.changeset(%Bonbon.Model.Cuisine.Region.Continent.Translation{}, %{ translate_id: 2, locale_id: en.id, term: "europe" }))
        fr_continent_europe = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.Continent.Translation.changeset(%Bonbon.Model.Cuisine.Region.Continent.Translation{}, %{ translate_id: 2, locale_id: fr.id, term: "europe" }))

        region_europe = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.changeset(%Bonbon.Model.Cuisine.Region{}, %{ continent: en_continent_europe.translate_id }))
        region_brisbane = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.changeset(%Bonbon.Model.Cuisine.Region{}, %{ continent: en_continent_oceania.translate_id, subregion: en_subregion_australasia.translate_id, country: en_country_australia.translate_id, province: en_province_brisbane.translate_id }))

        en_pasta = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Name.Translation.changeset(%Bonbon.Model.Cuisine.Name.Translation{}, %{ translate_id: 1, locale_id: en.id, term: "pasta" }))
        fr_pasta = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Name.Translation.changeset(%Bonbon.Model.Cuisine.Name.Translation{}, %{ translate_id: 1, locale_id: fr.id, term: "pâtes" }))

        en_lamington = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Name.Translation.changeset(%Bonbon.Model.Cuisine.Name.Translation{}, %{ translate_id: 2, locale_id: en.id, term: "lamington" }))
        fr_lamington = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Name.Translation.changeset(%Bonbon.Model.Cuisine.Name.Translation{}, %{ translate_id: 2, locale_id: fr.id, term: "lamington" }))

        cuisine_pasta = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.changeset(%Bonbon.Model.Cuisine{}, %{ name: en_pasta.translate_id, region_id: region_europe.id }))
        cuisine_lamington = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.changeset(%Bonbon.Model.Cuisine{}, %{ name: en_lamington.translate_id, region_id: region_brisbane.id }))

        db = %{
            en: %{
                cuisine: %{
                    pasta: %{ "id" => to_string(cuisine_pasta.id), "name" => en_pasta.term, "region" => %{ "id" => to_string(region_europe.id), "continent" => en_continent_europe.term, "subregion" => nil, "country" => nil, "province" => nil } },
                    lamington: %{ "id" => to_string(cuisine_lamington.id), "name" => en_lamington.term, "region" => %{ "id" => to_string(region_brisbane.id), "continent" => en_continent_oceania.term, "subregion" => en_subregion_australasia.term, "country" => en_country_australia.term, "province" => en_province_brisbane.term } }
                }
            },
            fr: %{
                cuisine: %{
                    pasta: %{ "id" => to_string(cuisine_pasta.id), "name" => fr_pasta.term, "region" => %{ "id" => to_string(region_europe.id), "continent" => fr_continent_europe.term, "subregion" => nil, "country" => nil, "province" => nil } },
                    lamington: %{ "id" => to_string(cuisine_lamington.id), "name" => fr_lamington.term, "region" => %{ "id" => to_string(region_brisbane.id), "continent" => fr_continent_oceania.term, "subregion" => fr_subregion_australasia.term, "country" => fr_country_australia.term, "province" => fr_province_brisbane.term } }
                }
            }
        }

        { :ok, %{ conn: conn, db: db } }
    end

    #cuisine
    @root :cuisine
    @fields [:id, :name, region: [:id, :continent, :subregion, :country, :province]]

    @tag locale: "en"
    test "get cuisine without id", %{ conn: conn } do
        assert "1 required argument (`id') not provided" == query_error(conn) #todo: possibly just check that an error was returned
    end

    #cuisine(id:)
    test_localisable_query("get cuisine with invalid id", nil, id: 0)

    test_localisable_query("get cuisine with id", &(&2[&1].cuisine.lamington), id: &(&1.en.cuisine.lamington["id"]))

    @tag locale: "en"
    test "get cuisine with non-integer id", %{ conn: conn } do
        assert _ = query_error(conn, id: "test") #todo: change to custom formatted message
    end
end
