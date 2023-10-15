defmodule Spotifyr.Accounts.Token do
  use Ash.Resource,
    data_layer: AshSqlite.DataLayer,
    extensions: [AshAuthentication.TokenResource]

  token do
    api Spotifyr.Accounts
  end

  sqlite do
    table "tokens"
    repo Spotifyr.Repo
  end
end
