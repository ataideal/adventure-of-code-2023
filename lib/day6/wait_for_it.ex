defmodule WaitForIt do
  alias Helper

  def solve do
    Helper.read_file!("6-input.txt")
    |> String.split("\n")
    |> parse_races()
    |> Enum.map(&calculate_race/1)
    |> Enum.product()
  end

  def solve2 do
    Helper.read_file!("6-input-2.txt")
    |> String.split("\n")
    |> parse_races()
    |> Enum.map(&calculate_race/1)
    |> Enum.product()
  end

  defp parse_races([time, distance]) do
    time = Regex.scan(~r/\d+/, time)
    distance = Regex.scan(~r/\d+/, distance)

    Enum.zip_reduce(time, distance, [], fn [x], [y], acc ->
      [[String.to_integer(x), String.to_integer(y)] | acc]
    end)
  end

  defp calculate_race([total_time, distance]) do
    Enum.reduce(1..total_time, 0, fn time, acc ->
        if time * (total_time - time) > distance, do: acc + 1, else: acc
    end)
  end
end
