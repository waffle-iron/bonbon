defmodule Bonbon.API.Account.UserTest do
    use Bonbon.APICase

    setup %{ conn: conn } do
        user_foo = Bonbon.Repo.insert!(Bonbon.Model.Account.User.changeset(%Bonbon.Model.Account.User{}, %{ email: "foo@foo", password: "test", name: "foo", mobile: "+123" }))
        user_bar = Bonbon.Repo.insert!(Bonbon.Model.Account.User.changeset(%Bonbon.Model.Account.User{}, %{ email: "bar@bar", password: "test", name: "bar", mobile: "+123" }))

        db = %{
            foo: user_foo,
            bar: user_bar
        }

        { :ok, %{ conn: conn, db: db } }
    end

    #register user
    @root :register_user
    @fields [
        :token
    ]

    test "invalid registration", %{ conn: conn } do
        for password <- [nil, { :password, "test"}],
            email <- [nil, { :email, "a@a" }],
            name <- [nil, { :name, "foo" }],
            mobile <- [nil, { :mobile, "+123" }] do
                case Enum.filter([password, email, name, mobile], &(&1 != nil)) do
                    [_, _, _, _] -> nil
                    args -> assert nil != mutation_error(conn, @root, @fields, args, :bad_request)
                end
        end
    end

    test "account exists", %{ conn: conn, db: db } do
        assert %{ "email" => "has already been taken" } = List.first(mutation(conn, @root, @fields, [email: db.foo.email, password: "1", name: "1", mobile: "+1"])["errors"])["field_errors"]
    end

    test "account registration", %{ conn: conn, db: db } do
        assert %{ "token" => jwt } = mutation_data(conn, @root, @fields, [email: db.foo.email <> "new", password: "1", name: "1", mobile: "+1"])
        assert { :ok, Bonbon.Model.Account.authenticate!(Bonbon.Model.Account.User, [email: db.foo.email <> "new", password: "1"]) } == Guardian.serializer.from_token(Guardian.decode_and_verify!(jwt)["sub"])
    end
end
