defmodule Bonbon.Model.Store do
    use Bonbon.Web, :model
    @moduledoc """
      A model representing the different stores.

      ##Fields

      ###:id
      Is the unique reference to the store entry. Is an `integer`.

      ###:public
      Whether the store is publicly listed or whether it is private (for use by [this](https://trello.com/c/K2HFzzo0)). Is a `boolean`.

      ###:status
      Is the current operating status of the store. Is a `Bonbon.Type.Store.StatusEnum`.

      ###:name
      Is the name of the store. Is a `string`.

      ###:phone
      Is the contact phone number of the store. Is a `string`.

      ###:address
      Is the address the store is located at. Is a `string`.

      ###:suburb
      Is the suburb the store is located in. Is a `string`.

      ###:state
      Is the state the store is located in. Is a `string`.

      ###:zip_code
      Is the zip code for where the store is located. Is a `string`.

      ###:country
      Is the country the store is located in. Is a `string`.

      ###:geo
      Is the geospatial coordinate the store is located at. Is a `Geo.Point`.

      ###:coordinates
      Is the longitude/latitude coordinate the store is located at. Is a `map`.

      ###:place
      Is the place/landmark/building the store is located inside (i.e. if it is
      inside a shopping centre's food court). Is a `string`.

      ###:pickup
      Whether the store allows for customer pickup. Is a `boolean`.

      ###:reservation
      Whether or not the store accepts reservations. Is a `boolean`.
    """

    schema "stores" do
        field :public, :boolean
        field :status, Bonbon.Type.Store.StatusEnum
        field :name, :string
        field :phone, :string
        field :address, :string
        field :suburb, :string
        field :state, :string
        field :zip_code, :string
        field :country, :string
        field :geo, Geo.Point
        field :coordinates, { :map, :float }, virtual: true
        field :place, :string
        field :pickup, :boolean
        field :reservation, :boolean
        timestamps
    end

    defp changeset(struct, params \\ %{}) do
        struct
        |> validate_phone_number(:phone)
        |> validate_map(:coordinates, [:latitude, :longitude])
        |> format_coordinate(:coordinates, :geo)
    end

    @doc """
      Builds a changeset for insertion based on the `struct` and `params`.

      Enforces:
      * `status` field is required
      * `name` field is required
      * `phone` field is required
      * `address` field is required
      * `suburb` field is required
      * `state` field is required
      * `country` field is required
      * `coordinates` field is required
      * `coordinates` field is a map containing the required fields `:latitude`
      and `:longitude`
      * `pickup` field is required
      * `reservation` field is required
      * `phone` field is a valid phone number
    """
    def insert_changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [:public, :status, :name, :phone, :address, :suburb, :state, :zip_code, :country, :coordinates, :place, :pickup, :reservation])
        |> validate_required([:status, :name, :phone, :address, :suburb, :state, :country, :coordinates, :pickup, :reservation])
        |> changeset(params)
    end

    @doc """
      Builds a changeset for updates based on the `struct` and `params`.

      Enforces:
      * `status` field is not empty
      * `name` field is not empty
      * `phone` field is not empty
      * `address` field is not empty
      * `suburb` field is not empty
      * `state` field is not empty
      * `country` field is not empty
      * `coordinates` field is not empty
      * `coordinates` field is a map containing the required fields `:latitude`
      and `:longitude`
      * `pickup` field is not empty
      * `reservation` field is not empty
      * `phone` field is a valid phone number
    """
    def update_changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [:public, :status, :name, :phone, :address, :suburb, :state, :zip_code, :country, :coordinates, :place, :pickup, :reservation])
        |> validate_emptiness(:status)
        |> validate_emptiness(:name)
        |> validate_emptiness(:phone)
        |> validate_emptiness(:address)
        |> validate_emptiness(:suburb)
        |> validate_emptiness(:state)
        |> validate_emptiness(:country)
        |> validate_emptiness(:coordinates)
        |> validate_emptiness(:pickup)
        |> validate_emptiness(:reservation)
        |> changeset(params)
    end

    def get_coordinates(%{ geo: %Geo.Point{ coordinates: { lng, lat }, srid: 4326 } }) do
        %{ latitude: lat, longitude: lng }
    end
end
