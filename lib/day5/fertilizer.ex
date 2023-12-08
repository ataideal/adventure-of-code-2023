defmodule Fertilizer do
  alias Helper

  @maps ~w[
    seeds
    seed-to-soil
    soil-to-fertilizer
    fertilizer-to-water
    water-to-light
    light-to-temperature
    temperature-to-humidity
    humidity-to-location
  ]
  def solve do
    Helper.read_file!("5-input.txt")
    |> String.split("\n")
    |> parse_input(0, List.first(@maps), %{}, true)
    |> find_seed_path()
    |> Enum.map(& List.last/1)
    |> Enum.min()
  end

  @inverse_maps Enum.reverse(@maps)
  @max_size 8
  def solve2 do
    start = NaiveDateTime.utc_now()
    map =
      Helper.read_file!("5-input.txt")
      |> String.split("\n")
      |> parse_input(0, List.first(@maps), %{}, true)
      |> Map.get_and_update("seeds", fn seeds ->
        new_seeds =
          seeds
          |> Enum.chunk_every(2)

        {seeds, new_seeds}
      end)
      |> elem(1)

    IO.inspect(start, label: :start)
    find_location_path(map, 0, List.first(@inverse_maps), [])
    IO.inspect(NaiveDateTime.utc_now(), label: :finish)
  end

  defp find_location_path(map, current_number, "seeds" = current_map, current_list) do
    Enum.find_value(map[current_map], fn [start, size] ->
      if current_number >= start && current_number <= start+size-1 do
        current_number
      end
    end)
    |> case do
      nil -> current_list
      seed_found -> [seed_found | current_list] |> IO.inspect(label: :match, charlists: :as_lists)
    end
  end

  defp find_location_path(map, current_number, "humidity-to-location" = current_map, current_list) do
    match_for_next_map =
      Enum.find_value(map[current_map], fn [drs, srs, size] ->
        if current_number >= drs && current_number <= drs+size-1 do
          current_number - drs + srs
        end
      end)
    if match_for_next_map do
      find_location_path(map, match_for_next_map, next_inverse_map(current_map), [current_number | current_list])
    else
      find_location_path(map, current_number, next_inverse_map(current_map), [current_number | current_list])
    end
    |> case do
      list when length(list) == @max_size -> list
      _ -> find_location_path(map, current_number + 1, current_map, current_list)
    end
  end

  defp find_location_path(map, current_number, current_map, current_list) do
    match_for_next_map =
      Enum.find_value(map[current_map], fn [drs, srs, size] ->
        if current_number >= drs && current_number <= drs+size-1 do
          current_number - drs + srs
        end
      end)
    if match_for_next_map do
      find_location_path(map, match_for_next_map, next_inverse_map(current_map), [current_number | current_list])
    else
      find_location_path(map, current_number, next_inverse_map(current_map), [current_number | current_list])
    end
  end

  defp find_seed_path(map) do
    Enum.map(map["seeds"], fn seed ->
      [seed | seed_path_list(map, seed, next_map("seeds"))]
    end)
  end

  defp seed_path_list(_map, _source_number, nil), do: []
  defp seed_path_list(map, source_number, current_step) do
    Enum.find_value(map[current_step], fn [drs, srs, size] ->
      case source_number in Range.new(srs, srs+size-1) do
        true -> source_number - srs + drs
        false -> nil
      end
    end)
    |> case do
      nil -> [source_number | seed_path_list(map, source_number, next_map(current_step))]
      new_source -> [new_source | seed_path_list(map, new_source, next_map(current_step))]
    end
  end

  defp parse_input(input, index, _current_map, acc, _verify) when index == length(input), do: acc

  defp parse_input(input, index, current_map, acc, true) do
    case Enum.at(input, index) == "" do
      true -> parse_input(input, index + 1, next_map(current_map), acc, false)
      false -> parse_input(input, index, current_map, acc, false)
    end
  end

  defp parse_input(input, index, current_map, acc, false) do
    new_seeds =
      Regex.scan(~r/\d+/, Enum.at(input, index))
      |> Enum.map(& List.first(&1) |> String.to_integer())

    acc = Map.update(acc, current_map, new_seeds, fn seeds -> [new_seeds | seeds] end)
    parse_input(input, index + 1, current_map, acc, true)
  end

  defp next_map(current_map) do
    next_index = Enum.find_index(@maps, & &1 == current_map) + 1
    Enum.at(@maps, next_index)
  end

  defp next_inverse_map(current_map) do
    next_index = Enum.find_index(@inverse_maps, & &1 == current_map) + 1
    Enum.at(@inverse_maps, next_index)
  end
end
