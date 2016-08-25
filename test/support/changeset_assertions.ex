defmodule Bonbon.ChangesetAssertions do
    import ExUnit.Assertions
    @moduledoc """
      Convenient chainable assertions for Ecto changesets.
    """

    @doc """
      Assert a change is valid.
    """
    def assert_change(model, params \\ %{}) do
        changeset = model.__struct__.changeset(model, params)
        assert changeset.valid?
        changeset
    end

    @doc """
      Assert a change is invalid.
    """
    def refute_change(model, params \\ %{}) do
        changeset = model.__struct__.changeset(model, params)
        refute changeset.valid?
        changeset
    end

    @doc """
      Assert a changed value is equal to value.
    """
    def assert_change_value(changeset, field, value) do
        assert value == changeset.changes[field]
        changeset
    end

    @doc """
      Assert a changed value is not equal to value.
    """
    def refute_change_value(changeset, field, value) do
        refute value == changeset.changes[field]
        changeset
    end

    @doc """
      Assert an error value is equal to value.
    """
    def assert_error_value(changeset, field, value) do
        assert value == changeset.errors[field]
        changeset
    end

    @doc """
      Assert an error value is not equal to value.
    """
    def refute_error_value(changeset, field, value) do
        refute value == changeset.errors[field]
        changeset
    end

    @doc """
      Assert an insertion produces the expected result and changeset.
    """
    def assert_insert(changeset, result) do
        assert { ^result, changeset } = Bonbon.Repo.insert(changeset)
        changeset
    end

    @doc """
      Assert an insertion does not produce the expected result and changeset.
    """
    def refute_insert(changeset, result) do
        refute { ^result, changeset } = Bonbon.Repo.insert(changeset)
        changeset
    end
end
