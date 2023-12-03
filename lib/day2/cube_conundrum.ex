defmodule CubeConundrum do
  alias Helper

  def solve do
    Helper.read_file!("2-input.txt")
    |> parse_input
    |> process_games(&max_set_per_color/2)
    |> Enum.with_index(1)
    |> Enum.reduce(0, fn {game_set, index}, acc ->
      if is_game_possible?(game_set) do
        acc + index
      else
        acc
      end
    end)
  end

  def solve2 do
    Helper.read_file!("2-input.txt")
    |> parse_input
    |> process_games(&max_set_per_color/2)
    |> Enum.reduce(0, fn game_set, acc ->
      acc + Enum.reduce(game_set, 1, fn {_color, value}, power -> value * power end)
    end)
  end

  defp parse_input(file) do
    file
    |> String.split("\n")
  end

  defp process_games(games, fun) do
    Enum.map(games, fn game ->
      # scan each set of colors in this game
      Regex.scan(~r/\s(\d+)\s(\w+)[,;]?/, game, capture: :all_but_first)
      |> Enum.reduce(%{}, fun)
    end)
  end

  defp max_set_per_color([amount, color], set_acc) do
    amount = String.to_integer(amount)
    max_value =
      case set_acc[color] do
        nil -> amount
        x when x > amount -> x
        _ -> amount
      end
    Map.put(set_acc, color, max_value)
  end

  @max_per_color %{
    "red" => 12,
    "green" => 13,
    "blue" => 14
  }
  defp is_game_possible?(game_set) do
    Enum.all?(game_set, fn {color, value} ->
      value <= Map.get(@max_per_color, color)
    end)
  end
end
