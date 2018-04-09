min_delegate
========
Helps you to easily define call and cast, info functions when using gen_server for elixir

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

If you use `min_delegate`

* It can reduce the functions that always define in two pair to one.
* It increases readibility in a way.
* It can reduce the possibility of errors.

In summary, when you use gen_server, can define and use it quickly.


## Installation

## Usage
