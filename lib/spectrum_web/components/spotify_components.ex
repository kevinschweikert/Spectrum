defmodule SpectrumWeb.SpotifyComponents do
  use Phoenix.Component
  use SpectrumWeb, :html
  # alias Phoenix.LiveView.JS

  attr :profile, Spotify.Profile, required: true

  def profile(assigns) do
    assigns =
      assigns
      |> assign(:avatar, List.first(assigns.profile.images, %{"url" => ""}) |> Map.get("url"))

    ~H"""
    <.avatar size="md" src={@avatar} />
    <.p>Name: <%= @profile.display_name %> - <%= @profile.country %></.p>
    <.p>ID: <%= @profile.id %></.p>
    <.p>Product: <%= @profile.product %></.p>
    """
  end

  attr :audio_features, Spotify.AudioFeatures, required: true

  def audio_features(assigns) do
    ~H"""
    <.label>Energy</.label>
    <.progress color="primary" value={@audio_features.energy} max={1} class="max-w-full" />
    <.label>Loudness</.label>
    <.progress color="secondary" value={@audio_features.loudness} max={1} class="max-w-full" />
    <.label>Danceability</.label>
    <.progress color="info" value={@audio_features.danceability} max={1} class="max-w-full" />
    <.label>Acousticness</.label>
    <.progress color="success" value={@audio_features.acousticness} max={1} class="max-w-full" />
    <.label>Instrumentalness</.label>
    <.progress color="warning" value={@audio_features.liveness} max={1} class="max-w-full" />
    <.label>Speechiness</.label>
    <.progress color="danger" value={@audio_features.speechiness} max={1} class="max-w-full" />
    <.label>Valence</.label>
    <.progress color="gray" value={@audio_features.valence} max={1} class="max-w-full" />
    """
  end
end
