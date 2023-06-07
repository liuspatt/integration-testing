defmodule Intst.Runner do
  require Intst.Utils

  def run(global_data, case_data, scenario) do
    data_case_global = Map.get(case_data, "global")
    data_case_global = prepare_data_with_generated_cases(data_case_global)
    run_data = Map.merge(global_data, data_case_global)
    run_scenario(scenario, run_data)
  end

  def run_scenario(scenario, run_data) do
    Enum.reduce(scenario, %{"data" => %{}}, fn map, acc ->
      type = Map.get(map, "type")
      request = Map.get(map, "request")
      data_to_save = Map.get(map, "data_to_save")
      data_case = Map.get(run_data, type)

      data_values =
        case data_case do
          nil ->
            run_data

          _ ->
            Map.merge(run_data, prepare_data_with_generated_cases(data_case))
        end

      data_values = Map.merge(Map.get(acc, "data"), data_values)
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

      # get save data
      body_response = Map.get(data, "body")
      # headers_response = Map.get(data, "headers")

      acc = Map.put(acc, type, body_response)

      acc =
        case data_to_save do
          nil ->
            acc

          _ ->
            result = prepare_values_to_saved(body_response, data_to_save)
            update_data_map(acc, result)
        end
    end)
  end

  def update_data_map(data_map, data) do
    pre_data = Map.get(data_map, "data")
    data_merged = Map.merge(pre_data, data)
    Map.replace!(data_map, "data", data_merged)
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

  def prepare_values(data_values, structure) when structure == nil do
    %{}
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

  def prepare_header_values(_, structure)
      when structure == nil or length(structure) == 0 do
    [{"Content-Type", "application/json"}]
  end

  def prepare_header_values(data_values, structure) do
    headers =
      Enum.reduce(structure, [], fn {key, value}, acc ->
        if Intst.Utils.is_fillable(value) do
          value_key = Intst.Utils.remove_braces(value)
          new_value = Map.get(data_values, value_key)
          {key, new_value}
        else
          {key, value}
        end
      end)

    [headers] ++ [{"Content-Type", "application/json"}]
  end

  def prepare_values_to_saved(data_values, structure) do
    Enum.reduce(structure, %{}, fn {key, value}, acc ->
      if Map.get(data_values, value) != nil do
        new_value = Map.get(data_values, value)
        Map.put(acc, key, new_value)
      end
    end)
  end

  def run_scenario(method, request, data_values) when method == :get do
    url = Map.get(request, "url")
    params = Map.get(request, "params")

    params = prepare_values(data_values, params)

    headers = Map.get(request, "headers")
    headers = prepare_header_values(data_values, headers)
    response = HTTPoison.get!(url, headers)

    case response.status_code do
      200 ->
        handle_success(response)

      _ ->
        handle_error(response)
    end
  end

  def run_scenario(method, request, data_values) when method == :post do
    url = Map.get(request, "url")
    body = Map.get(request, "body")
    body = prepare_values(data_values, body)
    body = Jason.encode!(body)

    params = Map.get(request, "params")
    params = prepare_values(data_values, params)

    headers = Map.get(request, "headers")
    headers = prepare_header_values(data_values, headers)

    options = [params: params, recv_timeout: 50000]
    response = HTTPoison.post!(url, body, headers, options)

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
      Jason.decode!(response.body),
      response.headers
    }
  end

  def handle_error(response) do
    # todo: add cases for retry, etc
    {
      :ok,
      response.status_code,
      Jason.decode!(response.body),
      response.headers
    }
  end
end
