defmodule Bonbon.Model.Account.Business.StoreListTest do
    use Bonbon.ModelCase

    alias Bonbon.Model.Account.Business.StoreList

    @valid_model %StoreList{
        business_id: 1,
        store_id: 1,
    }

    test "empty" do
        refute_change(%StoreList{})
    end

    test "only business_id" do
        refute_change(%StoreList{}, %{ business_id: 1 })
    end

    test "only store_id" do
        refute_change(%StoreList{}, %{ store_id: 1 })
    end

    test "without business_id" do
        refute_change(@valid_model, %{ business_id: nil })
    end

    test "without store_id" do
        refute_change(@valid_model, %{ store_id: nil })
    end

    test "uniqueness" do
        business = Bonbon.Repo.insert!(Bonbon.Model.Account.Business.registration_changeset(%Bonbon.Model.Account.Business{}, %{ email: "foo@foo", password: "test", name: "foo", mobile: "+123" }))
        store = Bonbon.Repo.insert!(Bonbon.Model.Store.insert_changeset(%Bonbon.Model.Store{}, %{ status: :closed, name: "Test", phone: "+123456789", address: "123 Address St", suburb: "Suburb", state: "State", zip_code: "1234", country: "Country", coordinates: %{ latitude: 0.0, longitude: 0.0 }, pickup: true, reservation: false }))

        item = Bonbon.Repo.insert!(StoreList.changeset(@valid_model, %{ business_id: business.id, store_id: store.id }))

        assert_change(@valid_model, %{ business_id: business.id, store_id: store.id })
        |> assert_insert(:error)
        |> assert_error_value(:store_id, { "has already been taken", [] })

        business2 = Bonbon.Repo.insert!(Bonbon.Model.Account.Business.registration_changeset(%Bonbon.Model.Account.Business{}, %{ email: "foo@bar", password: "test", name: "foo", mobile: "+123" }))
        store2 = Bonbon.Repo.insert!(Bonbon.Model.Store.insert_changeset(%Bonbon.Model.Store{}, %{ status: :closed, name: "Test2", phone: "+123456789", address: "123 Address St", suburb: "Suburb", state: "State", zip_code: "1234", country: "Country", coordinates: %{ latitude: 0.0, longitude: 0.0 }, pickup: true, reservation: false }))

        assert_change(@valid_model, %{ business_id: business2.id, store_id: store2.id })
        |> assert_insert(:ok)

        assert_change(@valid_model, %{ business_id: business.id, store_id: store2.id })
        |> assert_insert(:error)
        |> assert_error_value(:store_id, { "has already been taken", [] })

        business3 = Bonbon.Repo.insert!(Bonbon.Model.Account.Business.registration_changeset(%Bonbon.Model.Account.Business{}, %{ email: "bar@bar", password: "test", name: "foo", mobile: "+123" }))
        store3 = Bonbon.Repo.insert!(Bonbon.Model.Store.insert_changeset(%Bonbon.Model.Store{}, %{ status: :closed, name: "Test3", phone: "+123456789", address: "123 Address St", suburb: "Suburb", state: "State", zip_code: "1234", country: "Country", coordinates: %{ latitude: 0.0, longitude: 0.0 }, pickup: true, reservation: false }))

        assert_change(@valid_model, %{ business_id: business3.id, store_id: store3.id })
        |> assert_insert(:ok)

        store4 = Bonbon.Repo.insert!(Bonbon.Model.Store.insert_changeset(%Bonbon.Model.Store{}, %{ status: :closed, name: "Test4", phone: "+123456789", address: "123 Address St", suburb: "Suburb", state: "State", zip_code: "1234", country: "Country", coordinates: %{ latitude: 0.0, longitude: 0.0 }, pickup: true, reservation: false }))

        assert_change(@valid_model, %{ business_id: business.id, store_id: store4.id })
        |> assert_insert(:ok)
    end
end
