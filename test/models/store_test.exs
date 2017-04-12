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
        geo: %Geo.Point{ coordinates: { 0.0, 0.0 }, srid: 4326 },
        place: nil,
        pickup: true,
        reservation: false
    }

    test "empty" do
        refute_change(%Store{})
    end

    test "only public" do
        refute_change(%Store{}, %{ public: @valid_model.public })
    end

    test "only status" do
        refute_change(%Store{}, %{ status: @valid_model.status })
    end

    test "only name" do
        refute_change(%Store{}, %{ name: @valid_model.name })
    end

    test "only phone" do
        refute_change(%Store{}, %{ phone: @valid_model.phone })
    end

    test "only address" do
        refute_change(%Store{}, %{ address: @valid_model.address })
    end

    test "only suburb" do
        refute_change(%Store{}, %{ suburb: @valid_model.suburb })
    end

    test "only state" do
        refute_change(%Store{}, %{ state: @valid_model.state })
    end

    test "only zip_code" do
        refute_change(%Store{}, %{ zip_code: @valid_model.zip_code })
    end

    test "only country" do
        refute_change(%Store{}, %{ country: @valid_model.country })
    end

    test "only geo" do
        refute_change(%Store{}, %{ geo: @valid_model.geo })
    end

    test "only place" do
        refute_change(%Store{}, %{ place: @valid_model.place })
    end

    test "only pickup" do
        refute_change(%Store{}, %{ pickup: @valid_model.pickup })
    end

    test "only reservation" do
        refute_change(%Store{}, %{ reservation: @valid_model.reservation })
    end

    test "without public" do
        assert_change(@valid_model, %{ public: nil })
    end

    test "without status" do
        refute_change(@valid_model, %{ status: nil })
    end

    test "without name" do
        refute_change(@valid_model, %{ name: nil })
    end

    test "without phone" do
        refute_change(@valid_model, %{ phone: nil })
    end

    test "without address" do
        refute_change(@valid_model, %{ address: nil })
    end

    test "without suburb" do
        refute_change(@valid_model, %{ suburb: nil })
    end

    test "without state" do
        refute_change(@valid_model, %{ state: nil })
    end

    test "without zip_code" do
        assert_change(@valid_model, %{ zip_code: nil })
    end

    test "without country" do
        refute_change(@valid_model, %{ country: nil })
    end

    test "without geo" do
        refute_change(@valid_model, %{ geo: nil })
    end

    test "without place" do
        assert_change(@valid_model, %{ place: nil })
    end

    test "without pickup" do
        refute_change(@valid_model, %{ pickup: nil })
    end

    test "without reservation" do
        refute_change(@valid_model, %{ reservation: nil })
    end

    test "phone formatting" do
        refute_change(@valid_model, %{ phone: "123" })
        |> assert_error_value(:phone, { "should begin with a country prefix", [validation: :phone_number] })

        refute_change(@valid_model, %{ phone: "+123a" })
        |> assert_error_value(:phone, { "should contain the country prefix followed by only digits", [validation: :phone_number] })

        refute_change(@valid_model, %{ phone: "+" })
        |> assert_error_value(:phone, { "should contain between 1 and 18 digits", [validation: :phone_number] })

        refute_change(@valid_model, %{ phone: "+1234567890123456789" })
        |> assert_error_value(:phone, { "should contain between 1 and 18 digits", [validation: :phone_number] })
    end
end
