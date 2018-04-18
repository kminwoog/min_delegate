defmodule MinDelegateTest do
  use ExUnit.Case
  doctest MinDelegate

  @moduletag :min_delegate

  test "min_delegate" do
    {:ok, pid} = GenServer.start_link(MinDelegateQ, [], [])
    ret = MinDelegateQ.add_value(pid, 4)
    assert(ret == [4])
    ret = MinDelegateQ.add_value(pid, 1)
    assert(ret == [1, 4])
    MinDelegateQ.add_value_cast(pid, 2)
    ret = MinDelegateQ.add_value(pid, 3)
    assert(ret == [3, 2, 1, 4])
    MinDelegateQ.add_value_info(pid, 7)
    ret = MinDelegateQ.add_value(pid, 8)
    assert(ret == [8, 7, 3, 2, 1, 4])
    assert(MinDelegateQ.count(pid) == 6)
  end
end

defmodule MinDelegateQ do
  @moduledoc """
  Simple queue for testing min_delegate
  """

  use GenServer
  use MinDelegate

  ### GenServer Initializations
  def init(_state), do: {:ok, []}

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @alias :data
  defcall add_value(value, data) do
    data = [value | data]
    {:reply, data, data}
  end

  defcast add_value_cast(value, state) do
    {:noreply, [value | state]}
  end

  defcall count(state) do
    {:reply, length(state), state}
  end

  # #@whereis &whereis/1
  definfo add_value_info(value, state) do
    {:noreply, [value | state]}
  end

  # def whereis(id) do
  #   Registry.lookup(:min_delegate_app, id)
  # end
end
