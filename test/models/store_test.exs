defmodule Bonbon.StoreTest do
    use Bonbon.ModelCase

    alias Bonbon.Model.Store

    @valid_model %Store{
        public: true,
        status: :closed,
        name: "Test",
        phone: "+123456789",
        address: "123 Address St",
        suburb: "Suburb",
        state: "State",
        zip_code: "1234",
        country: "Country",
        coordinates: %{ latitude: 0.0, longitude: 0.0 },
        geo: %Geo.Point{ coordinates: { 0.0, 0.0 }, srid: 4326 },
        place: nil,
        pickup: true,
        reservation: false
    }

    test "empty" do
        refute_change(%Store{}, %{}, :insert_changeset)

        assert_change(@valid_model, %{}, :update_changeset)
    end

    test "only public" do
        refute_change(%Store{}, %{ public: @valid_model.public }, :insert_changeset)

        assert_change(@valid_model, %{ public: false }, :update_changeset)
    end

    test "only status" do
        refute_change(%Store{}, %{ status: @valid_model.status }, :insert_changeset)

        assert_change(@valid_model, %{ status: :open }, :update_changeset)
    end

    test "only name" do
        refute_change(%Store{}, %{ name: @valid_model.name }, :insert_changeset)

        assert_change(@valid_model, %{ name: "foo" }, :update_changeset)
    end

    test "only phone" do
        refute_change(%Store{}, %{ phone: @valid_model.phone }, :insert_changeset)

        assert_change(@valid_model, %{ phone: "+1234"}, :update_changeset)
    end

    test "only address" do
        refute_change(%Store{}, %{ address: @valid_model.address }, :insert_changeset)

        assert_change(@valid_model, %{ address: "foo" }, :update_changeset)
    end

    test "only suburb" do
        refute_change(%Store{}, %{ suburb: @valid_model.suburb }, :insert_changeset)

        assert_change(@valid_model, %{ suburb: "foo" }, :update_changeset)
    end

    test "only state" do
        refute_change(%Store{}, %{ state: @valid_model.state }, :insert_changeset)

        assert_change(@valid_model, %{ state: "foo" }, :update_changeset)
    end

    test "only zip_code" do
        refute_change(%Store{}, %{ zip_code: @valid_model.zip_code }, :insert_changeset)

        assert_change(@valid_model, %{ zip_code: "1000" }, :update_changeset)
    end

    test "only country" do
        refute_change(%Store{}, %{ country: @valid_model.country }, :insert_changeset)

        assert_change(@valid_model, %{ country: "foo" }, :update_changeset)
    end

    test "only coordinates" do
        refute_change(%Store{}, %{ coordinates: %{ longitude: 0, latitude: 0 } }, :insert_changeset)

        assert_change(@valid_model, %{ coordinates: %{ longitude: 10, latitude: 20 } }, :update_changeset)
    end

    test "only place" do
        refute_change(%Store{}, %{ place: @valid_model.place }, :insert_changeset)

        assert_change(@valid_model, %{ place: "foo" }, :update_changeset)
    end

    test "only pickup" do
        refute_change(%Store{}, %{ pickup: @valid_model.pickup }, :insert_changeset)

        assert_change(@valid_model, %{ pickup: false }, :update_changeset)
    end

    test "only reservation" do
        refute_change(%Store{}, %{ reservation: @valid_model.reservation }, :insert_changeset)

        assert_change(@valid_model, %{ reservation: true }, :update_changeset)
    end

    test "without public" do
        assert_change(@valid_model, %{ public: nil }, :insert_changeset)

        assert_change(@valid_model, %{ public: nil }, :update_changeset)
    end

    test "without status" do
        refute_change(@valid_model, %{ status: nil }, :insert_changeset)

        refute_change(@valid_model, %{ status: nil }, :update_changeset)
    end

    test "without name" do
        refute_change(@valid_model, %{ name: nil }, :insert_changeset)

        refute_change(@valid_model, %{ name: nil }, :update_changeset)
    end

    test "without phone" do
        refute_change(@valid_model, %{ phone: nil }, :insert_changeset)

        refute_change(@valid_model, %{ phone: nil }, :update_changeset)
    end

    test "without address" do
        refute_change(@valid_model, %{ address: nil }, :insert_changeset)

        refute_change(@valid_model, %{ address: nil }, :update_changeset)
    end

    test "without suburb" do
        refute_change(@valid_model, %{ suburb: nil }, :insert_changeset)

        refute_change(@valid_model, %{ suburb: nil }, :update_changeset)
    end

    test "without state" do
        refute_change(@valid_model, %{ state: nil }, :insert_changeset)

        refute_change(@valid_model, %{ state: nil }, :update_changeset)
    end

    test "without zip_code" do
        assert_change(@valid_model, %{ zip_code: nil }, :insert_changeset)

        assert_change(@valid_model, %{ zip_code: nil }, :update_changeset)
    end

    test "without country" do
        refute_change(@valid_model, %{ country: nil }, :insert_changeset)

        refute_change(@valid_model, %{ country: nil }, :update_changeset)
    end

    test "without coordinates" do
        refute_change(@valid_model, %{ coordinates: nil }, :insert_changeset)

        refute_change(@valid_model, %{ coordinates: nil }, :update_changeset)
    end

    test "without place" do
        assert_change(@valid_model, %{ place: nil }, :insert_changeset)

        assert_change(@valid_model, %{ place: nil }, :update_changeset)
    end

    test "without pickup" do
        refute_change(@valid_model, %{ pickup: nil }, :insert_changeset)

        refute_change(@valid_model, %{ pickup: nil }, :update_changeset)
    end

    test "without reservation" do
        refute_change(@valid_model, %{ reservation: nil }, :insert_changeset)

        refute_change(@valid_model, %{ reservation: nil }, :update_changeset)
    end

    test "coordinates formatting" do
        assert_change(@valid_model, %{ coordinates: %{ longitude: 10, latitude: 20 } }, :insert_changeset)
        |> assert_change_value(:geo, %Geo.Point{ coordinates: { 10.0, 20.0 }, srid: 4326 })

        refute_change(@valid_model, %{ coordinates: %{ latitude: 20 } }, :insert_changeset)
        |> assert_error_value(:coordinates, { "should contain all of the required fields", [validation: :map] })

        assert_change(@valid_model, %{ coordinates: %{ longitude: 10, latitude: 20 } }, :update_changeset)
        |> assert_change_value(:geo, %Geo.Point{ coordinates: { 10.0, 20.0 }, srid: 4326 })

        refute_change(@valid_model, %{ coordinates: %{ latitude: 20 } }, :update_changeset)
        |> assert_error_value(:coordinates, { "should contain all of the required fields", [validation: :map] })
    end

    test "phone formatting" do
        refute_change(@valid_model, %{ phone: "123" }, :insert_changeset)
        |> assert_error_value(:phone, { "should begin with a country prefix", [validation: :phone_number] })

        refute_change(@valid_model, %{ phone: "+123a" }, :insert_changeset)
        |> assert_error_value(:phone, { "should contain the country prefix followed by only digits", [validation: :phone_number] })

        refute_change(@valid_model, %{ phone: "+" }, :insert_changeset)
        |> assert_error_value(:phone, { "should contain between 1 and 18 digits", [validation: :phone_number] })

        refute_change(@valid_model, %{ phone: "+1234567890123456789" }, :insert_changeset)
        |> assert_error_value(:phone, { "should contain between 1 and 18 digits", [validation: :phone_number] })

        refute_change(@valid_model, %{ phone: "123" }, :update_changeset)
        |> assert_error_value(:phone, { "should begin with a country prefix", [validation: :phone_number] })

        refute_change(@valid_model, %{ phone: "+123a" }, :update_changeset)
        |> assert_error_value(:phone, { "should contain the country prefix followed by only digits", [validation: :phone_number] })

        refute_change(@valid_model, %{ phone: "+" }, :update_changeset)
        |> assert_error_value(:phone, { "should contain between 1 and 18 digits", [validation: :phone_number] })

        refute_change(@valid_model, %{ phone: "+1234567890123456789" }, :update_changeset)
        |> assert_error_value(:phone, { "should contain between 1 and 18 digits", [validation: :phone_number] })
    end
end
