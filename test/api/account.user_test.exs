defmodule Bonbon.API.Account.UserTest do
    use Bonbon.APICase

    setup %{ conn: conn } do
        user_foo = Bonbon.Repo.insert!(Bonbon.Model.Account.User.registration_changeset(%Bonbon.Model.Account.User{}, %{ email: "foo@foo", password: "test", name: "foo", mobile: "+123" }))
        user_bar = Bonbon.Repo.insert!(Bonbon.Model.Account.User.registration_changeset(%Bonbon.Model.Account.User{}, %{ email: "bar@bar", password: "test", name: "bar", mobile: "+123" }))

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

    #login user
    @root :login_user

    test "invalid login", %{ conn: conn } do
        for password <- [nil, { :password, "test"}],
            email <- [nil, { :email, "a@a" }] do
                case Enum.filter([password, email], &(&1 != nil)) do
                    [_, _] -> nil
                    args -> assert nil != mutation_error(conn, @root, @fields, args, :bad_request)
                end
        end
    end

    test "incorrect email", %{ conn: conn, db: db } do
        assert "Invalid credentials" == mutation_error(conn, [email: db.foo.email <> "other", password: db.foo.password])
    end

    test "incorrect password", %{ conn: conn, db: db } do
        assert "Invalid credentials" == mutation_error(conn, [email: db.foo.email, password: db.foo.password <> "other"])
    end

    test "correct credentials", %{ conn: conn, db: db } do
        assert %{ "token" => jwt } = mutation_data(conn, [email: db.foo.email, password: db.foo.password])
        assert { :ok, %{ db.foo | password: nil } } == Guardian.serializer.from_token(Guardian.decode_and_verify!(jwt)["sub"])

        assert %{ "token" => jwt } = mutation_data(conn, [email: db.bar.email, password: db.bar.password])
        assert { :ok, %{ db.bar | password: nil } } == Guardian.serializer.from_token(Guardian.decode_and_verify!(jwt)["sub"])
    end

    #logout user
    @root :logout_user

    test "invalid logout", %{ conn: conn } do
        assert nil != mutation_error(conn, @root, @fields, [], :bad_request)
    end

    test "invalid session logout", %{ conn: conn } do
        assert %{ "token" => nil } == mutation_data(conn, @root, @fields, [session: [token: "test"]])
    end

    test "valid session logout", %{ conn: conn, db: db } do
        session = %{ "token" => jwt } = mutation_data(conn, :login_user, @fields, [email: db.foo.email, password: db.foo.password])
        assert %{ "token" => nil } == mutation_data(conn, @root, @fields, [session: Map.to_list(session)])
        assert { :error, :token_not_found } == Guardian.decode_and_verify(jwt)
    end

    #get user
    @root :user
    @fields [
        :id,
        :name,
        :email,
        :mobile
    ]

    test "no session user query", %{ conn: conn } do
        assert "No current user account session" == query_error(conn)
    end

    test "invalid session user query", %{ conn: conn } do
        assert "No current user account session" == query_error(put_req_header(conn, "authorization", "test"))
    end

    test "valid session user query", %{ conn: conn, db: db } do
        %{ "token" => jwt } = mutation_data(conn, :login_user, [:token], [email: db.foo.email, password: db.foo.password])
        assert %{
            "id" => to_string(db.foo.id),
            "email" => db.foo.email,
            "name" => db.foo.name,
            "mobile" => db.foo.mobile
        } == query_data(put_req_header(conn, "authorization", "Bearer " <> jwt))
    end

    #update user
    @root :user
    @fields [
        :id,
        :name,
        :email,
        :mobile
    ]

    test "no session user update", %{ conn: conn } do
        assert "No current user account session" == mutation_error(conn)
    end

    test "invalid session user update", %{ conn: conn } do
        assert "No current user account session" == mutation_error(put_req_header(conn, "authorization", "test"))
    end

    test "valid session user update all fields", %{ conn: conn, db: db } do
        %{ "token" => jwt } = mutation_data(conn, :login_user, [:token], [email: db.foo.email, password: db.foo.password])
        assert %{
            "id" => to_string(db.foo.id),
            "email" => db.foo.email,
            "name" => "new",
            "mobile" => "+999"
        } == mutation_data(put_req_header(conn, "authorization", "Bearer " <> jwt), [name: "new", password: "new_pass", mobile: "+999"])

        assert "Invalid credentials" == mutation_error(conn, :login_user, [:token], [email: db.foo.email, password: db.foo.password])
        assert %{ "token" => _ } = mutation_data(conn, :login_user, [:token], [email: db.foo.email, password: "new_pass"])

        assert %{
            "id" => to_string(db.foo.id),
            "email" => db.foo.email,
            "name" => db.foo.name,
            "mobile" => db.foo.mobile
        } == mutation_data(put_req_header(conn, "authorization", "Bearer " <> jwt), [name: db.foo.name, password: db.foo.password, mobile: db.foo.mobile])
    end

    test "valid session user update name field", %{ conn: conn, db: db } do
        %{ "token" => jwt } = mutation_data(conn, :login_user, [:token], [email: db.foo.email, password: db.foo.password])
        assert %{
            "id" => to_string(db.foo.id),
            "email" => db.foo.email,
            "name" => "new",
            "mobile" => db.foo.mobile
        } == mutation_data(put_req_header(conn, "authorization", "Bearer " <> jwt), [name: "new"])

        assert %{
            "id" => to_string(db.foo.id),
            "email" => db.foo.email,
            "name" => db.foo.name,
            "mobile" => db.foo.mobile
        } == mutation_data(put_req_header(conn, "authorization", "Bearer " <> jwt), [name: db.foo.name])
    end

    test "valid session user update mobile field", %{ conn: conn, db: db } do
        %{ "token" => jwt } = mutation_data(conn, :login_user, [:token], [email: db.foo.email, password: db.foo.password])
        assert %{
            "id" => to_string(db.foo.id),
            "email" => db.foo.email,
            "name" => db.foo.name,
            "mobile" => "+999"
        } == mutation_data(put_req_header(conn, "authorization", "Bearer " <> jwt), [mobile: "+999"])

        assert %{
            "id" => to_string(db.foo.id),
            "email" => db.foo.email,
            "name" => db.foo.name,
            "mobile" => db.foo.mobile
        } == mutation_data(put_req_header(conn, "authorization", "Bearer " <> jwt), [mobile: db.foo.mobile])
    end

    test "valid session user update password field", %{ conn: conn, db: db } do
        %{ "token" => jwt } = mutation_data(conn, :login_user, [:token], [email: db.foo.email, password: db.foo.password])
        assert %{
            "id" => to_string(db.foo.id),
            "email" => db.foo.email,
            "name" => db.foo.name,
            "mobile" => db.foo.mobile
        } == mutation_data(put_req_header(conn, "authorization", "Bearer " <> jwt), [password: "new_pass"])

        assert "Invalid credentials" == mutation_error(conn, :login_user, [:token], [email: db.foo.email, password: db.foo.password])
        assert %{ "token" => _ } = mutation_data(conn, :login_user, [:token], [email: db.foo.email, password: "new_pass"])

        assert %{
            "id" => to_string(db.foo.id),
            "email" => db.foo.email,
            "name" => db.foo.name,
            "mobile" => db.foo.mobile
        } == mutation_data(put_req_header(conn, "authorization", "Bearer " <> jwt), [password: db.foo.password])
    end
end
