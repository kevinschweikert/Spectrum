defmodule Spotifyr.Accounts do
  use Ash.Api

  resources do
    resource Spotifyr.Accounts.User
    resource Spotifyr.Accounts.Token
  end
end
