min_delegate
========
[![Build Status](https://travis-ci.org/kminwoog/min_delegate.svg?branch=master)](https://travis-ci.org/kminwoog/min_delegate) [![Hex.pm Version](https://img.shields.io/hexpm/v/min_delegate.svg)](https://hex.pm/packages/min_delegate)

Helps you to easily define call and cast, info functions when using gen_server in elixir

## Overview

If you often use GenServer, define and implement the function as shown in the following example.

```elixir
defmodule SimpleServer do
  use GenServer

  ### GenServer Initializations
  def init(_state), do: {:ok, []}
  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  ### APIs for caller
  def add_value(value), do: GenServer.call(__MODULE__, {:add_value, value})

  @doc """
  GenServer.handle_call/3 callback
  """
  def handle_call({:add_value, value}, _from, state), do: {:reply, value, [value | state]}

end
```

If you are using `min_delegate`

* It can reduce the functions that always define in two pair to one.
* It increases readibility in a way.
* It can reduce the possibility of errors.

```elixir
defmodule MinDelegateQ do
  use GenServer
  use MinDelegate

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

  definfo add_value_info(value, state) do
    {:noreply, [value | state] }
  end
end

defmodule MinDelegateTest do
  use ExUnit.Case

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
```

In summary, when use gen_server, can define and use it quickly.


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `min_delegate` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:min_delegate, "~> 0.1.0"}
  ]
end
```

Then, run the following command to install

```sh
$ mix deps.get
```
## Usage

### :call method


```elixir
# define gen_server :call api
defcall your_func_name(arg0, arg1, arg2, state) do
  return = 1
  {:reply, return, state}
end
```

```elixir
# after expanding macro
def your_func_name(pid, arg0, arg1, arg2) do
  GenServer.call(pid, {:your_func_name, arg0, arg1, arg2})
end

def handle_call({:your_func_name, arg0, arg1, arg2}, _from, state) do
  return = 1
  {:reply, return, state}
end
```

### :cast method

It's similar with `:call` api.


### :info method

```elixir
# define gen_server :info api
definfo your_func_name(arg0, state) do
  state = put_in(state[:value], 2)
  {:noreply, state}
end
```

```elixir
# after expanding macro
def your_func_name(pid, arg0, delay \\ 0) do
  if delay > 0 do
    Process.send_after(pid, {:your_func_name, arg0}, delay)
  else
    send(pid, {:your_func_name, arg0})
  end
end

def handle_info({:your_func_name, arg0}, state) do
  state = put_in(state[:value], 2)
  {:noreply, state}
end
```

#### @alias attribute

Use `@alias` attribute to specify another name, not `state`

```elixir
@alias some
defcall your_func_name(arg0, arg1, some) do
  some = put_in(some[0], arg0)
  some = put_in(some[1], arg1)
  {:reply, return, some}
end
```


#### @whereis attribute

Not yet implemented
