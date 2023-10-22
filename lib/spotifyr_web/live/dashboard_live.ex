defmodule SpotifyrWeb.DashboardLive do
  use SpotifyrWeb, :live_view

  def mount(params, session, socket) do
    dbg()
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Dashboard</h1>
    """
  end
end
