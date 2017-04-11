defmodule Bonbon.Model.Store do
    use Bonbon.Web, :model
    @moduledoc """
      A model representing the different stores.
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
    """
    def changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [:public, :status, :name, :phone, :address, :suburb, :state, :zip_code, :country, :geo, :place, :pickup, :reservation])
        |> validate_required([:status, :name, :phone, :address, :suburb, :state, :country, :geo, :pickup, :reservation])
    end
end
