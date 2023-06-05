defmodule Intst.CLITest do
  use ExUnit.Case

  test "main runs successfully" do
    args = ["-d", "data_file.json", "-s", "scenario_file.json"]
    expected_cases = [%{"id" => "case1"}, %{"id" => "case2"}]
    expected_global_vars = %{"var1" => "value1", "var2" => "value2"}
    expected_scenario_info = %{"scenario" => "info"}

    Intst.CLI.stub(:read_json_file, fn
      "data_file.json" -> %{"cases" => expected_cases, "global_vars" => expected_global_vars}
      "scenario_file.json" -> expected_scenario_info
      _ -> nil
    end)

    assert capture_io(fn ->
             Intst.CLI.main(args)
           end) =~ "success"
  end

  test "main handles JSON file error" do
    args = ["-d", "data_file.json", "-s", "scenario_file.json"]

    Intst.CLI.stub(:read_json_file, fn
      _ -> {:error, "Failed to read JSON file"}
    end)

    assert capture_io(fn ->
             Intst.CLI.main(args)
           end) =~ "Failed to read JSON file"
  end

  test "main handles missing cases or global_vars" do
    args = ["-d", "data_file.json", "-s", "scenario_file.json"]

    Intst.CLI.stub(:read_json_file, fn
      _ -> %{}
    end)

    assert capture_io(fn ->
             Intst.CLI.main(args)
           end) =~ "Missing cases or global_vars"
  end
end
