defmodule Bonbon.Model.Account.UserTest do
    use Bonbon.ModelCase

    alias Bonbon.Model.Account.User

    @valid_model %User{
        email: "email@example.com",
        name: "Foo Bar",
        password: "test",
        password_hash: "test",
        mobile: "+123456789"
    }

    test "empty" do
        refute_change(%User{})
    end

    test "only email" do
        refute_change(%User{}, %{ email: @valid_model.email })
    end

    test "only name" do
        refute_change(%User{}, %{ name: @valid_model.name })
    end

    test "only mobile" do
        refute_change(%User{}, %{ mobile: @valid_model.mobile })
    end

    test "only password" do
        refute_change(%User{}, %{ password: @valid_model.password })
    end

    test "without email" do
        refute_change(@valid_model, %{ email: nil })
    end

    test "without name" do
        refute_change(@valid_model, %{ name: nil })
    end

    test "without mobile" do
        refute_change(@valid_model, %{ mobile: nil })
    end

    test "without password" do
        refute_change(@valid_model, %{ password: nil })
    end

    test "valid model" do
        assert_change(@valid_model)
    end

    test "email formatting" do
        refute_change(@valid_model, %{ email: "test" })
        |> assert_error_value(:email, { "should contain a local part and domain separated by '@'", [validation: :email] })

        refute_change(@valid_model, %{ email: "@" })
        |> assert_error_value(:email, { "should contain a local part and domain separated by '@'", [validation: :email] })

        refute_change(@valid_model, %{ email: "test@" })
        |> assert_error_value(:email, { "should contain a local part and domain separated by '@'", [validation: :email] })
    end

    test "mobile formatting" do
        refute_change(@valid_model, %{ mobile: "123" })
        |> assert_error_value(:mobile, { "should begin with a country prefix", [validation: :phone_number] })

        refute_change(@valid_model, %{ mobile: "+123a" })
        |> assert_error_value(:mobile, { "should contain the country prefix followed by only digits", [validation: :phone_number] })

        refute_change(@valid_model, %{ mobile: "+" })
        |> assert_error_value(:mobile, { "should contain between 1 and 18 digits", [validation: :phone_number] })

        refute_change(@valid_model, %{ mobile: "+1234567890123456789" })
        |> assert_error_value(:mobile, { "should contain between 1 and 18 digits", [validation: :phone_number] })
    end

    test "password hashing" do
        assert_change(@valid_model)
        |> refute_change_field(:password_hash)

        assert_change(@valid_model, %{ password: "pass" })
        |> assert_change_field(:password_hash)
    end

    test "uniqueness" do
        user = Bonbon.Repo.insert!(@valid_model)

        assert_change(@valid_model, %{ email: @valid_model.email })
        |> assert_insert(:error)
        |> assert_error_value(:email, { "has already been taken", [] })

        assert_change(@valid_model, %{ email: @valid_model.email <> ".test" })
        |> assert_insert(:ok)

        assert_change(@valid_model, %{ email: "test" <> @valid_model.email })
        |> assert_insert(:ok)
    end

    test "authenticate" do
        user_foo = Bonbon.Repo.insert!(User.changeset(%User{}, %{ email: "foo@foo", password: "test", name: "foo", mobile: "+123" }))
        user_bar = Bonbon.Repo.insert!(User.changeset(%User{}, %{ email: "bar@bar", password: "test", name: "bar", mobile: "+123" }))

        assert { :ok, %{ user_foo | password: nil } } == Bonbon.Model.Account.authenticate(User, email: "foo@foo", password: "test")
        assert { :ok, %{ user_bar | password: nil } } == Bonbon.Model.Account.authenticate(User, email: "bar@bar", password: "test")
    end
end
