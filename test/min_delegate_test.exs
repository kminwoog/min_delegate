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
