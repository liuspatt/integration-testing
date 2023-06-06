defmodule Intst.Runner do
  require Intst.Utils

  def run(global_data, case_data, scenario) do
    data_case_global = Map.get(case_data, "global")
    data_case_global = prepare_data_with_generated_cases(data_case_global)
    run_data = Map.merge(global_data, data_case_global)

    for map <- scenario do
      type = Map.get(map, "type")
      request = Map.get(map, "request")
      data_case = Map.get(run_data, type)

      data_values =
        case data_case do
          nil ->
            run_data

          _ ->
            prepared_data = prepare_data_with_generated_cases(data_case)
            Map.merge(run_data, prepared_data)
        end

      IO.puts("data_case: #{inspect(data_case)}")
      method = Map.get(request, "method") |> String.downcase() |> String.to_atom()

      response = run_scenario(method, request, data_values)

      data =
        case response do
          {:ok, _, body, headers} ->
            %{
              "body" => body,
              "headers" => headers
            }

          {:error, status, body, headers} ->
            IO.puts("ERROR: #{inspect(status)}")
            IO.puts("ERROR: #{inspect(body)}")
            IO.puts("ERROR: #{inspect(headers)}")
            System.halt(1)
        end

      IO.inspect(data)

      # save response values in global_data
    end
  end

  def prepare_data_with_generated_cases(data_case) when data_case == nil do
    %{}
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
    IO.puts("scenario get: #{inspect(data)}")
  end

  def run_scenario(method, request, data_values) when method == :post do
    url = Map.get(request, "url")

    body = Map.get(request, "body")
    body = prepare_values(data_values, body)
    body = Jason.encode!(body)
    headers = Map.get(request, "headers")
    headers = prepare_values(data_values, headers)
    headers = [{"Content-Type", "application/json"}]

    # Realizar la solicitud POST
    IO.puts("url post: #{inspect(url)}")
    IO.puts("body post: #{inspect(body)}")
    IO.puts("headers post: #{inspect(headers)}")

    response = HTTPoison.post!(url, body, headers)

    # Manejar la respuesta
    case response.status_code do
      200 ->
        handle_success(response)

      _ ->
        handle_error(response)
    end
  end

  def handle_success(response) do
    # todo: add timings and other metrics
    {
      :ok,
      response.status_code,
      response.body,
      response.headers
    }
  end

  def handle_error(response) do
    # todo: add cases for retry, etc
    {
      :ok,
      response.status_code,
      response.body,
      response.headers
    }
  end
end
