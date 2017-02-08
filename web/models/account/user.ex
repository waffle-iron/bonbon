defmodule Bonbon.Account.User do
    use Bonbon.Web, :model
    @moduledoc """
      A model representing the different user accounts.
    """

    schema "users" do
        field :email, :string
        field :password, :string, virtual: true
        field :password_hash, :string
        field :mobile, :string
        field :name, :string
        timestamps
    end

    @doc """
      Builds a changeset based on the `struct` and `params`.
    """
    def changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [:email, :password, :mobile, :name])
        |> validate_required([:email, :password, :mobile, :name])
        |> validate_phone_number(:mobile)
        |> validate_email(:email)
        |> format_hash(:password)
        #todo: active_phone_number(:mobile) check that the phone number exists
        #todo: active_email(:email) check that the email exists
    end
end
