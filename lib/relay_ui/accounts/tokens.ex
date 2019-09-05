defmodule RelayUi.Accounts.Tokens do
  alias Phoenix.Token
  alias RelayUiWeb.Endpoint

  @login_request_max_age 60 * 15 # 15 minutes
  # TODO: move the salt to the config file
  @login_request_salt "fNIOjClIzoRwQZ5L4mUdG5k/3pl9vwh+8Sqmtk1s2vJUDLbp/s0t5n5/JM+yvXdO"

  def sign_login_request(login_request) do
    Token.sign(Endpoint, @login_request_salt, login_request.id)
  end

  def verify_login_request(token) do
    Token.verify(Endpoint, @login_request_salt, token, max_age: @login_request_max_age)
  end

end

