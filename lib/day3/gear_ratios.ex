defmodule GearRatios do
  alias Helper

  def solve do
    file = Helper.read_file!("3-input.txt")
    |> String.split("\n")

    numbers_indexes = Enum.map(file, fn line -> Regex.scan(~r/\d+/, line,  return: :index) end)
    symbols_indexes = Enum.map(file, fn line -> Regex.scan(~r/[^\d.]+/, line,  return: :index) end)

    dbg(numbers_indexes)
    dbg(symbols_indexes)

    numbers_indexes
    |> Enum.with_index()
    |> Enum.map(fn {indexes, number_line} ->
      numbers_adjacents_line =
        indexes
        |> List.flatten()
        |> Enum.filter(&check_adjacent_symbol(&1, number_line, symbols_indexes))

      {numbers_adjacents_line, number_line}
    end)
    |> Enum.reduce(0, fn {numbers_adjacents, index}, line_acc ->
      line = Enum.at(file, index)
      Enum.reduce(numbers_adjacents, 0, fn {start_n, end_n} , acc ->
        line
        |> String.slice(start_n, end_n)
        |> IO.inspect()
        |> String.to_integer()
        |> Kernel.+(acc)
      end)
      |> IO.inspect()
      |> Kernel.+(line_acc)
    end)
  end

  def solve2 do
    file = Helper.read_file!("3-input.txt")
    |> String.split("\n")

    numbers_indexes = Enum.map(file, fn line -> Regex.scan(~r/\d+/, line,  return: :index) end)
    symbols_indexes = Enum.map(file, fn line -> Regex.scan(~r/\*/, line,  return: :index) end)

    symbols_indexes
    |> Enum.with_index()
    |> Enum.map(fn {indexes, number_line} ->
      indexes
      |> List.flatten()
      |> Enum.reduce([], &numbers_adjacent_to_symbol(&1, &2, number_line, numbers_indexes))
    end)
    |> Enum.reduce(0, fn list, acc -> process_matches(list, file) + acc end)
  end

  defp check_adjacent_symbol({start_index, number_size}, 0, symbols_indexes) do
    [
      Enum.at(symbols_indexes, 0),
      Enum.at(symbols_indexes, 1)
    ]
    |> do_verify_adjacent_symbol(start_index, start_index + number_size)
  end

  defp check_adjacent_symbol({start_index, number_size}, number_line, symbols_indexes) when length(symbols_indexes) == number_line + 1 do
    [
      Enum.at(symbols_indexes, number_line - 1),
      Enum.at(symbols_indexes, number_line)
    ]
    |> do_verify_adjacent_symbol(start_index, start_index + number_size)
  end


  defp check_adjacent_symbol({start_index, number_size}, number_line, symbols_indexes) do
    [
      Enum.at(symbols_indexes, number_line - 1),
      Enum.at(symbols_indexes, number_line),
      Enum.at(symbols_indexes, number_line + 1)
    ]
    |> do_verify_adjacent_symbol(start_index, start_index + number_size)
  end

  defp do_verify_adjacent_symbol(symbols_list, start_number, end_number) do
    symbols_list
    |> List.flatten()
    |> Enum.any?(fn {start_symbol, symbol_size} ->
      symbol_range = Range.new(start_symbol - 1, start_symbol + symbol_size)
      number_range = Range.new(start_number, end_number - 1)
      Range.disjoint?(number_range, symbol_range) == false
    end)
  end

  defp numbers_adjacent_to_symbol({start_symbol, symbol_size}, acc, number_line, numbers_indexes) do
    numbers_adjacent =
      case number_line do
        0 ->
          [
            add_line_reference_and_take(numbers_indexes, 0),
            add_line_reference_and_take(numbers_indexes, 1)
          ]
        x when x + 1 == length(numbers_indexes) ->
          [
            add_line_reference_and_take(numbers_indexes, number_line - 1),
            add_line_reference_and_take(numbers_indexes, number_line)
          ]
        _ ->
          [
            add_line_reference_and_take(numbers_indexes, number_line - 1),
            add_line_reference_and_take(numbers_indexes, number_line),
            add_line_reference_and_take(numbers_indexes, number_line + 1)
          ]
      end
      |> List.flatten()
      |> Enum.filter(fn {start_number, number_size, _line} ->
        symbol_range = Range.new(start_symbol - 1, start_symbol + symbol_size)
        number_range = Range.new(start_number, start_number + number_size - 1)
        Range.disjoint?(number_range, symbol_range) == false
      end)
    [numbers_adjacent | acc]
  end

  defp add_line_reference_and_take(numbers_indexes, i) do
    numbers_indexes
    |> Enum.at(i)
    |> List.flatten()
    |> Enum.map(fn {s, e} -> {s, e, i} end)
  end

  #[{6, 3, 7}, {5, 3, 9}], [{6, 3, 7}, {5, 3, 9}]
  defp process_matches([], _file), do: 0
  defp process_matches(list, file) do
    Enum.reduce(list, 0, fn
      [number_1, number_2], acc -> fetch_number(number_1, file) * fetch_number(number_2, file) + acc
      _, acc -> acc
    end)
  end

  defp fetch_number({start, size, line}, file) do
    file
    |> Enum.at(line)
    |> String.slice(start, size)
    |> String.to_integer()
  end
end
