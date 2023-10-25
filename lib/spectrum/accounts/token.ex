defmodule Spectrum.Accounts.Token do
  use Ash.Resource,
    data_layer: AshSqlite.DataLayer,
    extensions: [AshAuthentication.TokenResource]

  token do
    api Spectrum.Accounts
  end

  sqlite do
    table "tokens"
    repo Spectrum.Repo
  end
end
