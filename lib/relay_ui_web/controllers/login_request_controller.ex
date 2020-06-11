defmodule RelayUiWeb.LoginRequestController do
  use RelayUiWeb, :controller

  alias RelayUi.Accounts.LoginRequests
  alias RelayUi.Email
  alias RelayUi.Mailer

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"login_request" => %{"email" => email}}) do
    case LoginRequests.create(email) do
      {:ok, %{login_request: login_request}, user} ->
        user
        |> Email.login_request(login_request)
        |> Mailer.deliver_now()

        conn
        |> put_flash(:info, "We just emailed a temporary login link. Please check your email")
        |> redirect(to: Routes.page_path(conn, :index))

      {:error, :not_found} ->
        conn
        |> put_flash(:info, "Sorry email does not exist")
        |> render("new.html")
    end
  end

  def show(conn, %{"token" => token}) do
    case LoginRequests.redeem(token) do
      {:ok, %{session: session}} ->
        conn
        |> put_flash(:info, "Logged in successfully.")
        |> put_session(:session_id, session.id)
        |> configure_session(renew: true)
        |> redirect(to: Routes.page_path(conn, :admin))

      {:error, :expired} ->
        conn
        |> put_flash(:error, "Login link expired")
        |> render("new.html")

      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Login not valid")
        |> render("new.html")
    end
  end
end
