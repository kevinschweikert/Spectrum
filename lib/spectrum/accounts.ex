defmodule Spectrum.Accounts do
  use Ash.Api

  resources do
    resource Spectrum.Accounts.User
    resource Spectrum.Accounts.Token
  end
end
