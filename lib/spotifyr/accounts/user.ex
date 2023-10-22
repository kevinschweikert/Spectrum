defmodule Spotifyr.Accounts.User do
  use Ash.Resource,
    data_layer: AshSqlite.DataLayer,
    extensions: [AshAuthentication]

  attributes do
    uuid_primary_key :id
    attribute :email, :ci_string, allow_nil?: false
    attribute :hashed_password, :string, allow_nil?: false, sensitive?: true
    # TODO: encrypt these
    # TODO: seperate resource for spotify credentials
    attribute :spotify_access_token, :string, allow_nil?: true, sensitive?: true
    attribute :spotify_refresh_token, :string, allow_nil?: true, sensitive?: true
  end

  code_interface do
    define_for Spotifyr.Accounts
    define :spotify_credentials, args: [:user_id]
    define :update_spotify_credentials, args: [:credentials, {:optional, :last_refresh}]
  end

  actions do
    read :spotify_credentials do
      get? true

      argument :user_id, :uuid do
        allow_nil? false
      end

      prepare build(
                select: [:spotify_access_token, :spotify_refresh_token],
                limit: 1,
                load: [:spotify_valid?]
              )

      filter expr(id == ^arg(:user_id))
    end

    update :update_spotify_credentials do
      accept []

      argument :credentials, :struct do
        allow_nil? false
        constraints instance_of: Spotify.Credentials
      end

      argument :last_refresh, :utc_datetime do
        default &DateTime.utc_now/0
      end

      change fn changeset, _ ->
        case Ash.Changeset.fetch_argument(changeset, :credentials) do
          {:ok, credentials} ->
            changeset
            |> Ash.Changeset.change_attribute(:spotify_access_token, credentials.access_token)
            |> Ash.Changeset.change_attribute(:spotify_refresh_token, credentials.refresh_token)

          :error ->
            changeset
        end
      end

      change set_attribute(:spotify_last_refresh, arg(:last_refresh))
    end
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
