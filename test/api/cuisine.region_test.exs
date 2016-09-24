defmodule Bonbon.API.Cuisine.RegionTest do
    use Bonbon.APICase

    setup %{ conn: conn } do
        en = Bonbon.Repo.insert!(%Bonbon.Model.Locale{ language: "en" })
        fr = Bonbon.Repo.insert!(%Bonbon.Model.Locale{ language: "fr" })

        en_continent = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.Continent.Translation.changeset(%Bonbon.Model.Cuisine.Region.Continent.Translation{}, %{ translate_id: 1, locale_id: en.id, term: "africa" }))
        fr_continent = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.Continent.Translation.changeset(%Bonbon.Model.Cuisine.Region.Continent.Translation{}, %{ translate_id: 1, locale_id: fr.id, term: "afrique" }))
        en_subregion = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.Subregion.Translation.changeset(%Bonbon.Model.Cuisine.Region.Subregion.Translation{}, %{ translate_id: 1, locale_id: en.id, term: "central africa" }))
        fr_subregion = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.Subregion.Translation.changeset(%Bonbon.Model.Cuisine.Region.Subregion.Translation{}, %{ translate_id: 1, locale_id: fr.id, term: "afrique centrale" }))
        en_country = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.Country.Translation.changeset(%Bonbon.Model.Cuisine.Region.Country.Translation{}, %{ translate_id: 1, locale_id: en.id, term: "gabon" }))
        fr_country = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.Country.Translation.changeset(%Bonbon.Model.Cuisine.Region.Country.Translation{}, %{ translate_id: 1, locale_id: fr.id, term: "gabon" }))
        en_province = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.Province.Translation.changeset(%Bonbon.Model.Cuisine.Region.Province.Translation{}, %{ translate_id: 1, locale_id: en.id, term: "estuaire" }))
        fr_province = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.Province.Translation.changeset(%Bonbon.Model.Cuisine.Region.Province.Translation{}, %{ translate_id: 1, locale_id: fr.id, term: "estuaire" }))

        region_africa = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.changeset(%Bonbon.Model.Cuisine.Region{}, %{ continent: en_continent.translate_id }))
        region_central_africa = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.changeset(%Bonbon.Model.Cuisine.Region{}, %{ continent: en_continent.translate_id, subregion: en_subregion.translate_id }))
        region_gabon = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.changeset(%Bonbon.Model.Cuisine.Region{}, %{ continent: en_continent.translate_id, subregion: en_subregion.translate_id, country: en_country.translate_id }))
        region_estuaire = Bonbon.Repo.insert!(Bonbon.Model.Cuisine.Region.changeset(%Bonbon.Model.Cuisine.Region{}, %{ continent: en_continent.translate_id, subregion: en_subregion.translate_id, country: en_country.translate_id, province: en_province.translate_id }))

        db = %{
            en: %{
                region: %{
                    estuaire: %{ "id" => to_string(region_estuaire.id), "continent" => en_continent.term, "subregion" => en_subregion.term, "country" => en_country.term, "province" => en_province.term },
                    gabon: %{ "id" => to_string(region_gabon.id), "continent" => en_continent.term, "subregion" => en_subregion.term, "country" => en_country.term, "province" => nil },
                    central_africa: %{ "id" => to_string(region_central_africa.id), "continent" => en_continent.term, "subregion" => en_subregion.term, "country" => nil, "province" => nil },
                    africa: %{ "id" => to_string(region_africa.id), "continent" => en_continent.term, "subregion" => nil, "country" => nil, "province" => nil }
                }
            },
            fr: %{
                region: %{
                    estuaire: %{ "id" => to_string(region_estuaire.id), "continent" => fr_continent.term, "subregion" => fr_subregion.term, "country" => fr_country.term, "province" => fr_province.term },
                    gabon: %{ "id" => to_string(region_gabon.id), "continent" => fr_continent.term, "subregion" => fr_subregion.term, "country" => fr_country.term, "province" => nil },
                    central_africa: %{ "id" => to_string(region_central_africa.id), "continent" => fr_continent.term, "subregion" => fr_subregion.term, "country" => nil, "province" => nil },
                    africa: %{ "id" => to_string(region_africa.id), "continent" => fr_continent.term, "subregion" => nil, "country" => nil, "province" => nil }
                }
            }
        }

        { :ok, %{ conn: conn, db: db } }
    end

    #region
    @root :region
    @fields [:id, :continent, :subregion, :country, :province]

    @tag locale: "en"
    test "get region without id", %{ conn: conn, db: db } do
        assert "1 required argument (`id') not provided" == query_error(conn) #todo: possibly just check that an error was returned
    end

    #region(id:)
    test_localisable_query("get region with invalid id", nil, id: 0)

    test_localisable_query("get region with id", &(&2[&1].region.gabon), id: &(&1.en.region.gabon["id"]))

    @tag locale: "en"
    test "get region with non-integer id", %{ conn: conn, db: db } do
        assert _ = query_error(conn, id: "test") #todo: change to custom formatted message
    end
end
