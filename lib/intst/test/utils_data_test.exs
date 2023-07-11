defmodule UtilDataTest do
  use ExUnit.Case
  require Intst.Utils
  require Intst.Runner
  doctest Intst

  test "generate with data url" do
    url = "https://be-service--gcp--ue.a.run.app/br/{{id}}"
    data_values = %{"id" => "123"}
    url = Intst.Runner.prepare_values(data_values, %{"url" => url})
    IO.inspect(url, label: "url")
    url = Map.get(url, "url")
  end

end
