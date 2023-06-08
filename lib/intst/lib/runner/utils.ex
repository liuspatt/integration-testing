defmodule Intst.Utils do
  @random_length 6
  @chars "abcdefghijklmnopqrstuvwxyz" |> String.split("")
  @regex_letterts ~r/{\[a-z\]random}/
  @regex_numbers ~r/{\[0-9\]random}/

  def generate_random() do
    Enum.reduce(1..@random_length, [], fn _i, acc ->
      [Enum.random(@chars) | acc]
    end)
    |> Enum.join("")
  end

  def generate_random_number() do
    Enum.reduce(1..@random_length, [], fn _i, acc ->
      [Enum.random(0..9) | acc]
    end)
    |> Enum.join("")
  end

  def process_string(string) when is_number(string), do: string

  def process_string(string) do
    string =
      case Regex.match?(@regex_letterts, string) do
        true -> String.replace(string, @regex_letterts, generate_random())
        _ -> string
      end

    string =
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
end
