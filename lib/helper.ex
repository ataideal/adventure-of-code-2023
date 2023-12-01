defmodule Helper do
  def read_file!(file_name) do
    case File.read("inputs/" <> file_name) do
      {:ok, file} -> file
      {:error, error} -> raise error
    end
  end
end
