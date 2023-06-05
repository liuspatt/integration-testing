defmodule Intst.Runner do
  require Intst.Utils

  def run(global_data, case_data, scenario) do
    for map <- scenario do
      type = Map.get(map, "type")
      request = Map.get(map, "request")
      data_case = Map.get(case_data, type)

      if data_case == nil do
        IO.puts("ERROR: #{type} not found in case data")
        IO.puts("case_data: #{inspect(case_data)}")
        System.halt(1)
      end

      data_case = prepare_data_with_generated_cases(data_case)
      method = Map.get(request, "method") |> String.downcase() |> String.to_atom()
      data_values = Map.merge(global_data, data_case)
      run_scenario(method, request, data_values)
    end
  end

  def prepare_data_with_generated_cases(data_case) do
    data_case
    |> Enum.reduce(%{}, fn {key, value}, acc ->
      new_value = Intst.Utils.process_string(value)
      Map.put(acc, key, new_value)
    end)
  end

  def prepare_values(data_values, structure) do
    Enum.reduce(structure, %{}, fn {key, value}, acc ->
      if Intst.Utils.is_fillable(value) do
        value_key = Intst.Utils.remove_braces(value)
        new_value = Map.get(data_values, value_key)
        Map.put(acc, key, new_value)
      else
        Map.put(acc, key, value)
      end
    end)
  end

  def prepare_query(global_data, case_data, scenario) do
    IO.puts("global_data: #{inspect(global_data)}")
    IO.puts("case_data: #{inspect(case_data)}")
    IO.puts("scenario: #{inspect(scenario)}")
  end

  def run_scenario(method, scenario, data) when method == :get do
    IO.puts("scenario get: #{inspect(scenario)}")
  end

  def run_scenario(method, request, data_values) when method == :post do
    url = Map.get(request, "url")

    body = Map.get(request, "body")
    body = prepare_values(data_values, body)
    body = Jason.encode!(body)
    headers = Map.get(request, "headers")
    headers = prepare_values(data_values, headers)

    # Realizar la solicitud POST
    IO.puts("url post: #{inspect(url)}")
    IO.puts("body post: #{inspect(body)}")
    IO.puts("headers post: #{inspect(headers)}")

    response = HTTPoison.post!(url, body, [{"Content-Type", "application/json"},{"data", "some"}])

    IO.puts("headers post: #{inspect(response)}")
    # Manejar la respuesta
    case response.status_code do
      200 ->
        handle_success(response)
      _ ->
        handle_error(response)
    end
  end

  def handle_success(response) do
    IO.puts("Request successful!")
    IO.puts("Response body: #{inspect(response.body)}")
    IO.puts("Response headers: #{inspect(response.headers)}")
  end

  def handle_error(response) do
    IO.puts("Request failed!")
    IO.puts("Status code: #{response.status_code}")
    IO.puts("Response body: #{inspect(response.body)}")
    IO.puts("Response headers: #{inspect(response.headers)}")
  end
end
