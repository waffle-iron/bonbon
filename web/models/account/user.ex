defmodule Bonbon.Model.Account.User do
    use Bonbon.Web, :model
    @moduledoc """
      A model representing the different user accounts.

      ##Fields

      ###:id
      Is the unique reference to the user entry. Is an `integer`.

      ###:email
      Is the email of the user. Is a `string`.

      ###:password
      Is the password of the user. Is a `string`.

      ###:password_hash
      Is the hash of the user's password. Is a `string`.

      ###:mobile
      Is the mobile of the user. Is a `string`.

      ###:name
      Is the name of the user. Is a `string`.
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
      Builds a changeset for registration based on the `struct` and `params`.

      Enforces:
      * `email` field is required
      * `password` field is required
      * `mobile` field is required
      * `name` field is required
      * `mobile` field is a valid mobile number
      * `email` field is a valid email
      * `email` field is unique
    """
    def registration_changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [:email, :password, :mobile, :name])
        |> validate_required([:email, :password, :mobile, :name])
        |> validate_phone_number(:mobile)
        |> validate_email(:email)
        |> format_hash(:password)
        |> unique_constraint(:email)
        #todo: active_phone_number(:mobile) check that the phone number exists
        #todo: active_email(:email) check that the email exists
    end
end
