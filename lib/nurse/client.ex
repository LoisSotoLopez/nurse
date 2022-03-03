defmodule Nurse.Client do
  @type error :: :timeout | :recv_timeout | :unknown

  @spec request(
          Nurse.endpoint(),
          Nurse.request(),
          Nurse.connection_timeout(),
          Nurse.response_timeout()
        ) :: {:ok, Nurse.response()} | {:error, error()}
  def request(
        {scheme, hostname, port},
        {method, headers, body},
        connection_timeout \\ 8000,
        response_timeout \\ 5000
      ) do
    url = scheme <> "://" <> hostname <> ":" <> Integer.to_string(port)

    case HTTPoison.request(method, url, body, headers, [
           {:timeout, connection_timeout},
           {:recv_timeout, response_timeout}
         ]) do
      {:ok, %HTTPoison.Response{status_code: status_code, headers: recv_headers, body: recv_body}} ->
        {:ok, {status_code, recv_headers, recv_body}}

      {:error, %HTTPoison.Error{reason: :timeout}} ->
        {:error, :timeout}

      {:error, %HTTPoison.Error{reason: :recv_timeout}} ->
        {:error, :recv_timeout}

      _other ->
        {:error, :unknown}
    end
  end
end
