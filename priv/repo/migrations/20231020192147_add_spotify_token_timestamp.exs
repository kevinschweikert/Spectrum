defmodule Spectrum.Repo.Migrations.MigrateResources1 do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_sqlite.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:users) do
      add :spotify_last_refresh, :utc_datetime
    end
  end

  def down do
    alter table(:users) do
      remove :spotify_last_refresh
    end
  end
end
