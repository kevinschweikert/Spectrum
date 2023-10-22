defmodule SpotifyrWeb.SpotifyController do
  use SpotifyrWeb, :controller

  require Logger

  def login(conn, _params) do
    render(conn, :login)
  end

  def authorize(conn, _params) do
    redirect(conn, external: Spotify.Authorization.url())
  end

  def authenticate(conn, params) do
    creds =
      Spotifyr.Spotify.credentials(conn.assigns.current_user.id) ||
        Spotify.Credentials.new(params)

    case Spotify.Authentication.authenticate(creds, params) do
      {:ok, creds} ->
        dbg(creds)

        case Spotifyr.Spotify.save_credentials(conn.assigns.current_user, creds) do
          {:ok, user} ->
            conn |> assign(:current_user, user)

          {:error, reason} ->
            Logger.error("Saving credentials failed: #{inspect(reason)}")
            redirect(conn, to: "/error")
        end

        redirect(conn, to: "/dashboard")

      {:error, reason, conn} ->
        Logger.error("Authentication failed: #{inspect(reason)}")
        redirect(conn, to: "/error")
    end
  end

  def logout(conn, _params) do
    case Spotifyr.Accounts.User.update_spotify_credentials(
           conn.assigns.current_user,
           %Spotify.Credentials{}
         ) do
      {:ok, user} ->
        conn |> assign(:current_user, user) |> redirect(to: "/spotify/login")

      {:error, reason} ->
        Logger.error("Logout failed: #{inspect(reason)}")
        redirect(conn, to: "/error")
    end
  end
end
