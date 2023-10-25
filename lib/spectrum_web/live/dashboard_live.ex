defmodule SpectrumWeb.DashboardLive do
  use SpectrumWeb, :live_view

  import SpectrumWeb.SpotifyComponents

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_async(:me, fn ->
       result_to_async_result(Spectrum.Spotify.get_profile(socket.assigns.current_user), :me)
     end)
     |> assign(:track_form, to_form(%{"url" => ""}))
     |> assign(:track_audio_features, nil)}
  end

  def render(assigns) do
    ~H"""
    <.h1>Dashboard</.h1>

    <.h2>Your Profile</.h2>

    <.async_result :let={me} assign={@me}>
      <:loading>Loading profile...</:loading>
      <:failed :let={reason}>
        there was an error loading the organization: <%= inspect(reason) %>
      </:failed>
      <.profile profile={me} />
    </.async_result>

    <.simple_form for={@track_form} phx-submit="save">
      <SpectrumWeb.CoreComponents.input label="Track URL" field={@track_form[:url]} />
      <:actions>
        <.button>Get Track Data</.button>
      </:actions>
    </.simple_form>

    <%= if @track_audio_features do %>
      <.audio_features audio_features={@track_audio_features} />
    <% end %>
    """
  end

  def handle_event("save", %{"url" => url}, socket) do
    <<"/track/", track_id::binary>> = URI.parse(url).path

    {:ok, audio_features} =
      Spectrum.Spotify.get_audio_features(socket.assigns.current_user, track_id)

    {:noreply, assign(socket, :track_audio_features, audio_features)}
  end

  defp result_to_async_result({:ok, result}, key) when is_atom(key) do
    {:ok, Map.put(%{}, key, result)}
  end

  defp result_to_async_result({:error, reason}, key) when is_atom(key) do
    {:error, Map.put(%{}, key, reason)}
  end
end
