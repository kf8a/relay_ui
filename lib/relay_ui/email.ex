defmodule RelayUi.Email do
  use Bamboo.Phoenix, view: RelayUiWeb.EmailView
  import Bamboo.Email

  alias RelayUi.Accounts.Tokens

  def login_request(user, login_request) do
    new_email()
    |> to(user.email)
    |> from("support@gashog.kbs.msu.edu")
    |> subject("Login to GasHog")
    |> assign(:token, Tokens.sign_login_request(login_request))
    |> render("login_request.html")
  end
end
