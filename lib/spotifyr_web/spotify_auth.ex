defmodule SpotifyrWeb.SpotifyAuth do
  import Phoenix.Controller

  require Logger

  def init(_), do: []

  @doc """
  Checks for existing Spotify tokens in the `current_user`. Requires an existing user in the `conn.assigns`.
  """
  def require_spotify_tokens(conn, _) do
    if is_nil(conn.assigns.current_user.spotify_access_token) and
         is_nil(conn.assigns.current_user.spotify_refresh_token) do
      conn
      |> put_flash(
        :error,
        "Für den Zugang zu dieser Seite ist eine Anmeldung bei Spotify erforderlich."
      )
      |> redirect(to: "/spotify/login")
    else
      conn
    end
  end
end
