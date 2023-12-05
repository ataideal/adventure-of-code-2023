defmodule Scratchcard do
  alias Helper

  def solve do
    Helper.read_file!("4-input.txt")
    |> parse_scratchcards()
    |> match_numbers()
    |> calculate_points()
  end

  def solve2 do
    Helper.read_file!("4-input.txt")
    |> parse_scratchcards()
    |> match_numbers()
    |> calculate_copies()
  end

  defp parse_scratchcards(input) do
    input
    |> String.split("\n")
    |> Enum.flat_map(fn game ->
      Regex.scan(~r/Card\s+\d+: ([\d+\s+]+)\| ([\d+\s+]+)/, game, capture: :all_but_first)
    end)
    |> Enum.map(fn [winning_number, card_number] ->
      {
        Regex.scan(~r/\d+/, winning_number) |> Enum.map(& List.first(&1) |> String.to_integer()),
        Regex.scan(~r/\d+/, card_number) |> Enum.map(& List.first(&1) |> String.to_integer())
      }
    end)
  end

  defp match_numbers(score_cards) do
    Enum.map(score_cards, fn {winning_number, card_number} ->
      MapSet.intersection(MapSet.new(winning_number), MapSet.new(card_number))
      |> MapSet.to_list()
    end)
  end

  defp calculate_points(number_hits) do
    Enum.reduce(number_hits, 0, fn
      [], acc -> acc
      [_], acc -> acc + 1
      list, acc -> acc + Integer.pow(2, length(list) - 1)
    end)
  end

  defp calculate_copies(number_hits) do
    number_hits
    |> IO.inspect(charlists: :as_lists)
    |> Enum.with_index(1)
    |> Enum.reduce(%{}, fn {list, index}, acc ->
        # Update Original card
        acc = Map.update(acc, index, 1, fn existing_value -> existing_value + 1 end)
        increment = Map.get(acc, index)
        # Add copies to other cards
        copy_cards(increment, index + 1, length(list), acc)
    end)
    |> Map.values()
    |> Enum.sum()
  end

  defp copy_cards(_increment, _index, 0, acc), do: acc

  defp copy_cards(increment, index, k, acc) do
    acc = Map.update(acc, index, increment, fn existing_value -> existing_value + increment end)
    copy_cards(increment, index + 1, k - 1, acc)
  end
end
