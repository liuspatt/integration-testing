defmodule Intst.CLI do
  require Logger
  require Intst.Runner

  def main(args) do
    options = [
      switches: [data: :string, scenario: :string, vus: :string],
      aliases: [d: :file, s: :file, v: :file]
    ]

    {opts, _, _} = OptionParser.parse(args, options)

    required_options = [:data, :scenario]

    # missing_options = Enum.filter(required_options, fn(option) -> Map.get(options, option) == nil end)
    # unless Enum.empty?(missing_options) do
    #   IO.puts "ERROR: : #{inspect missing_options}"
    #   System.halt(1)
    # end

    {cases, global_vars} =
      read_json_file(opts[:data])
      |> (fn data -> {Map.get(data, "cases"), Map.get(data, "global_vars")} end).()

    scenario_info = read_json_file(opts[:scenario])

    for map <- cases do
      Intst.Runner.run(global_vars, map, scenario_info)
    end
  end

  def launch_error(value_erro) do
    IO.puts("ERROR: --#{value_erro} missing")
    System.halt(1)
  end

  def read_json_file(file_name) do
    case File.read(file_name) do
      {:ok, content} ->
        case Jason.decode(content) do
          {:ok, data} ->
            data

          {:error, reason} ->
            Logger.error("Failed to parse JSON file: #{reason}")
            nil
        end

      {:error, reason} ->
        Logger.error("Failed to read JSON file: #{reason}")
        nil
    end
  end
end
