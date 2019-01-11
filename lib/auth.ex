defmodule FirebaseAdminEx.Auth do
  alias FirebaseAdminEx.{Request, Response, Errors}

  @auth_endpoint "https://www.googleapis.com/identitytoolkit/v3/relyingparty/"
  @auth_scope "https://www.googleapis.com/auth/cloud-platform"

  @doc """
  Get a user's info by UID
  """
  @spec get_user(String.t(), String.t() | nil) :: tuple()
  def get_user(uid, client_email \\ nil), do: get_user(:localId, uid, client_email)

  @doc """
  Get a user's info by phone number
  """
  @spec get_user_by_phone_number(String.t(), String.t() | nil) :: tuple()
  def get_user_by_phone_number(phone_number, client_email \\ nil),
    do: get_user(:phone_number, phone_number, client_email)

  @doc """
  Get a user's info by email
  """
  @spec get_user_by_email(String.t(), String.t() | nil) :: tuple()
  def get_user_by_email(email, client_email \\ nil),
    do: get_user(:email, email, client_email)

  defp get_user(key, value, client_email),
    do: do_request("getAccountInfo", %{key => value}, client_email)

  @doc """
  Delete an existing user by UID
  """
  @spec delete_user(String.t(), String.t() | nil) :: tuple()
  def delete_user(uid, client_email \\ nil),
    do: do_request("deleteAccount", %{localId: uid}, client_email)

  # TODO: Add other commands:
  # list_users
  # create_user
  # update_user
  # import_users

  defp do_request(url_suffix, payload, client_email) do
    with {:ok, response} <-
           Request.request(
             :post,
             @auth_endpoint <> url_suffix,
             payload,
             auth_header(client_email)
           ),
         {:ok, body} <- Response.parse(response) do
      {:ok, body}
    else
      {:error, error} -> raise Errors.ApiError, Kernel.inspect(error)
    end
  end

  defp auth_header(nil) do
    {:ok, token} = Goth.Token.for_scope(@auth_scope)

    do_auth_header(token.token)
  end

  defp auth_header(client_email) do
    {:ok, token} = Goth.Token.for_scope({client_email, @auth_scope})

    do_auth_header(token.token)
  end

  defp do_auth_header(token) do
    %{"Authorization" => "Bearer #{token}"}
  end
end
