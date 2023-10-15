defmodule Spotifyr.Accounts.User do
  use Ash.Resource,
    data_layer: AshSqlite.DataLayer,
    extensions: [AshAuthentication]

  attributes do
    uuid_primary_key :id
    attribute :email, :ci_string, allow_nil?: false
    attribute :hashed_password, :string, allow_nil?: false, sensitive?: true
  end

  authentication do
    api Spotifyr.Accounts

    strategies do
      password :password do
        identity_field :email
      end
    end

    tokens do
      enabled? true
      token_resource Spotifyr.Accounts.Token
      signing_secret Spotifyr.Accounts.Secrets
    end
  end

  sqlite do
    table "users"
    repo Spotifyr.Repo
  end

  identities do
    identity :unique_email, [:email]
  end
end
