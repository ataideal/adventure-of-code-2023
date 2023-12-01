defmodule Trebuchet do
  alias Helper

  def solve do
    file = Helper.read_file!("1-input.txt")
    Regex.scan(~r/\D*(\d)?.*(\d).*\n/, file)
    |> Enum.reduce(0, fn
      [_, "", y], acc ->  String.to_integer(y)*10 + String.to_integer(y) + acc
      [_, x, y], acc -> String.to_integer(x)*10 +  String.to_integer(y) + acc
    end)
  end

  def solve2 do
    file = Helper.read_file!("1-input.txt")
    Regex.scan(~r/(one|two|three|four|five|six|seven|eight|nine|\d)(?>.*(one|two|three|four|five|six|seven|eight|nine|\d))?.*\n/, file)
    |> Enum.reduce(0, fn
      [_, x], acc ->  to_integer(x)*10 + to_integer(x) + acc
      [_, x, y], acc -> to_integer(x)*10 +  to_integer(y) + acc
    end)
  end

  @number %{
    "one" => "1",
    "two" => "2",
    "three" => "3",
    "four" => "4",
    "five" => "5",
    "six" => "6",
    "seven" => "7",
    "eight" => "8",
    "nine" => "9"
  }
  defp to_integer(s), do: Map.get(@number, s, s) |> String.to_integer

end
