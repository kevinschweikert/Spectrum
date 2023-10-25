defmodule Spectrum.Spotify do
  alias Spectrum.Accounts.User

  def credentials(user_id) do
    case User.spotify_credentials(user_id) do
      {:ok, user} ->
        credentials_from_user(user)

      {:error, _} ->
        nil
    end
  end

  def save_credentials(%Spectrum.Accounts.User{} = user, %Spotify.Credentials{} = creds) do
    User.update_spotify_credentials(user, creds)
  end

  def get_profile(%User{} = user) do
    Spotify.Profile.me(credentials_from_user(user))
    |> handle_spotify_response(user, &get_profile/1, [user])
  end

  def get_audio_features(%User{} = user, track_id) when is_binary(track_id) do
    Spotify.Track.audio_features(credentials_from_user(user), track_id)
    |> handle_spotify_response(user, &get_audio_features/2, [user, track_id])
  end

  @spec credentials_from_user(User.t()) :: Spotify.Credentials.t()
  defp credentials_from_user(%User{} = user) do
    Spotify.Credentials.new(
      user.spotify_access_token,
      user.spotify_refresh_token
    )
  end

  @spec handle_spotify_response(term(), User.t(), (any -> any), [any]) ::
          {:ok, any} | {:error, any}
  defp handle_spotify_response(response, user, callback, args)

  defp handle_spotify_response({:ok, struct}, user, _callback, _args)
       when is_struct(struct) and is_struct(user) do
    {:ok, struct}
  end

  defp handle_spotify_response({:ok, %{"error" => %{"status" => 401}}}, user, callback, args)
       when is_struct(user) and is_function(callback) and is_list(args) do
    with {:ok, creds} <- Spotify.Authentication.refresh(credentials_from_user(user)),
         {:ok, _user} <- save_credentials(user, creds) do
      apply(callback, [args])
    else
      {:error, _} ->
        {:error, "Failed to refresh credentials"}
    end
  end

  defp handle_spotify_response({:error, _}, _user, _callback, _args) do
    {:error, "Failed to fetch resource"}
  end
end
