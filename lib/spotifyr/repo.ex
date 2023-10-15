defmodule Spotifyr.Repo do
  use Ecto.Repo,
    otp_app: :spotifyr,
    adapter: Ecto.Adapters.Postgres
end
