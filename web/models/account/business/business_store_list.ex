defmodule Bonbon.Model.Account.Business.BusinessStoreList do
    use Bonbon.Web, :model
    @moduledoc """
      A model representing the different stores owned by the business.
    """

    schema "business_store_list" do
        belongs_to :business, Bonbon.Model.Account.Business
        belongs_to :store, Bonbon.Model.Store
        timestamps
    end

    @doc """
      Builds a changeset based on the `struct` and `params`.
    """
    def changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [:business_id, :store_id])
        |> validate_required([:business_id, :store_id])
        |> assoc_constraint(:business)
        |> assoc_constraint(:store)
        |> unique_constraint(:business_id_store_id)
    end
end
