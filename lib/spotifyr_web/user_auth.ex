defmodule SpotifyrWeb.UserAuth do
  @moduledoc """
  Helpers for authenticating users in liveviews
  """

  import Phoenix.Controller
  import Plug.Conn
  use SpotifyrWeb, :verified_routes

  def on_mount(:live_user_optional, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:cont, socket}
    else
      {:cont, Phoenix.Component.assign_new(socket, :current_user, fn -> nil end)}
    end
  end

  def on_mount(:live_user_required, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:cont, socket}
    else
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/sign-in")}
    end
  end

  def on_mount(:live_no_user, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/")}
    else
      {:cont, Phoenix.Component.assign_new(socket, :current_user, fn -> nil end)}
    end
  end

  @doc """
  Used for routes that require the user to not be authenticated.
  """
  def redirect_if_user_is_authenticated(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
      |> redirect(to: signed_in_path(conn))
      |> halt()
    else
      conn
    end
  end

  @doc """
  Used for routes that require the user to be authenticated.
  """
  def require_authenticated_user(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "Für den Zugang zu dieser Seite ist eine Anmeldung erforderlich.")
      |> redirect(to: ~p"/sign-in")
      |> halt()
    end
  end

  defp signed_in_path(_conn), do: ~p"/dashboard"
end
