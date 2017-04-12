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
        field :place, :string
        field :pickup, :boolean
        field :reservation, :boolean
        timestamps
    end

    @doc """
      Builds a changeset based on the `struct` and `params`.

      Enforces:
      * `status` field is required
      * `name` field is required
      * `phone` field is required
      * `address` field is required
      * `suburb` field is required
      * `state` field is required
      * `country` field is required
      * `geo` field is required
      * `pickup` field is required
      * `reservation` field is required
      * `phone` field is a valid phone number
    """
    def changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [:public, :status, :name, :phone, :address, :suburb, :state, :zip_code, :country, :geo, :place, :pickup, :reservation])
        |> validate_required([:status, :name, :phone, :address, :suburb, :state, :country, :geo, :pickup, :reservation])
        |> validate_phone_number(:phone)
    end
end
