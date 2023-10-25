defmodule SpectrumWeb.Router do
  use SpectrumWeb, :router
  use AshAuthentication.Phoenix.Router
  import SpectrumWeb.UserAuth
  import SpectrumWeb.SpotifyAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {SpectrumWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_from_session
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :load_from_bearer
  end

  scope "/", SpectrumWeb do
    pipe_through :browser

    get "/", PageController, :home

    get "/authorize", SpotifyController, :authorize
    get "/authenticate", SpotifyController, :authenticate
    get "/spotify/login", SpotifyController, :login

    # add these lines -->
    # Leave out `register_path` and `reset_path` if you don't want to support
    # user registration and/or password resets respectively.
    sign_in_route(
      register_path: "/register",
      reset_path: "/reset",
      on_mount: [{SpectrumWeb.UserAuth, :live_no_user}]
    )

    sign_out_route AuthController
    auth_routes_for Spectrum.Accounts.User, to: AuthController
    reset_route []
    # <-- add these lines
  end

  scope "/", SpectrumWeb do
    pipe_through [:browser, :require_authenticated_user, :require_spotify_tokens]

    get "/spotify/logout", SpotifyController, :logout

    ash_authentication_live_session :authentication_required,
      on_mount: {SpectrumWeb.UserAuth, :live_user_required} do
      live "/dashboard", DashboardLive
    end
  end

  # Other scopes may use custom stacks.
  scope "/api", SpectrumWeb do
    pipe_through :api
    get "/me", SpotifyController, :me
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:spectrum, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: SpectrumWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
