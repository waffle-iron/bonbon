defmodule Bonbon.Repo.Migrations.CreateStore do
    use Ecto.Migration

    def change do
        Bonbon.Type.Store.StatusEnum.create_type

        create table(:stores) do
            add :status, :store_status,
                null: false

            add :name, :string, #todo: check if store's would want to offer a translated name?
                null: false

            add :phone, :string,
                null: false

            #todo: should normalize addresses? (may be difficult)
            add :address, :string,
                null: false

            add :suburb, :string,
                null: false

            add :state, :string,
                null: false

            add :zip_code, :string

            add :country, :string,
                null: false

            add :geo, :geometry,
                null: false

            #todo: add :floor?

            add :place, :string

            #todo: delivery opt-ins
            #todo: deliverable times
            #todo: delivery region (if self-handled)
            #todo: delivery cost coverage (if self-handled)
            #todo: delivery cost coverage (if third party)

            add :pickup, :boolean,
                null: false

            add :reservation, :boolean,
                null: false

            #todo: decor

            timestamps
        end
    end
end
