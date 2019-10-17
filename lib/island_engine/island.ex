defmodule IslandEngine.Island do
    alias __MODULE__
    alias IslandEngine.Coordinate

    @enforce_keys [:coordinates, :hit_coordinates]
    defstruct [:coordinates, :hit_coordinates]

    def new(type, %Coordinate{} = upper_left) do
        with [_|_] = offsets <- offset(type), %MapSet{} = coordinates <- add_coordinates(offsets, upper_left) do
            {:ok, %Island{coordinates: coordinates, hit_coordinates: MapSet.new()}}
        else
            error -> error
        end
    end

    defp offset(:square), do: [{0,0},{0,1},{1,0},{1,1}]
    defp offset(:atoll), do: [{0,0},{0,1},{1,1},{2,0},{2,1}]
    defp offset(:dot), do: [{0,0}]
    defp offset(:l_shape), do: [{0,0},{1,0},{2,0},{2,1}]
    defp offset(:s_shape), do: [{0,1},{0,2},{1,0},{1,1}]
    defp offset(_), do: {:error, :invalide_island_type}

    defp add_coordinates(offsets, upper_left) do
        Enum.reduce_while(offsets, MapSet.new(), fn offset, acc ->
            add_coordinate(acc, upper_left, offset)
        end)
    end

    defp add_coordinate(coordinates, %Coordinate{row: row, col: col}, {offset_row, offset_col}) do
        case Coordinate.new(row + offset_row, col + offset_col) do
            {:ok, coordinate} -> {:cont, MapSet.put(coordinates, coordinate)}
            {:error, :invalid_coordinate} -> {:halt, {:error, :invalid_coordinate}}
        end
    end
end