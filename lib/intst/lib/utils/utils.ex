defmodule Intst.Utils do
  @chars "abcdefghijklmnopqrstuvwxyz" |> String.graphemes()
  @regex_letterts ~r/{\[a-z\]random}/
  @regex_numbers ~r/{\[0-9\]random}/
  def generate_random(length \\ 6) do
    Enum.reduce(1..length, [], fn _i, acc ->
      [Enum.random(@chars) | acc]
    end)
    |> Enum.join("")
  end


  def generate_random_number(length \\ 6) do
    min = trunc(:math.pow(10, length - 1))
    max = trunc(:math.pow(10, length) - 1)
    Enum.random(min..max)
  end

  def process_string(string) when is_number(string), do: string

  def process_string(string) do
    string =
      case Regex.match?(@regex_letterts, string) do
        true -> String.replace(string, @regex_letterts, generate_random())
        _ -> string
      end

    case Regex.match?(@regex_numbers, string) do
      true -> String.replace(string, @regex_numbers, generate_random_number())
      _ -> string
    end
  end

  def is_fillable(string) do
    case Regex.run(~r/{{\w+}}/, string) do
      [_ | _] -> true
      _ -> false
    end
  end

  def remove_braces(string) do
    String.replace(string, ~r/{{(.*?)}}/, "\\1")
  end

  def extract_values(text) do
    Regex.scan(~r/{{(.*?)}}/, text)
    |> Enum.map(&List.first/1)
  end

  def replace_values(text, values) do
    values_list = extract_values(text)
    IO.inspect(values_list, label: "values_list")

    Enum.reduce(values_list, text, fn {key}, acc ->
      key = remove_braces(key)
      String.replace(acc, "{{#{key}}}", Map.get(values, key))
    end)
  end
end
