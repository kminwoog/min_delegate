defmodule MinDelegate do
  @moduledoc """
  This MinDelegate module
  helps to define the client APIs and the server callbacks of GenServer.

  #### `@alias` attribute

    Use `@alias` attribute to specify another name, not `state`

      defmodule Arithmetic do
        @alias data
        defcast add_op(value1, value2, data) do
          data = put_in(data[:add], value1 + value2)
          {:reply, data.add, data}
        end
      end

  """

  @doc false
  defmacro __using__(_opts) do
    quote do
      unless Module.get_attribute(__MODULE__, :min_delegate) do
        attributes = [
          :min_delegate,
          :alias
        ]

        if Enum.any?(attributes, &Module.get_attribute(__MODULE__, &1)) do
          raise "you must set @alias after the call to \"use MinDelegate\""
        end

        Enum.each(attributes, &Module.register_attribute(__MODULE__, &1, []))
      end

      # , only: [min_delegate: 2]
      import MinDelegate
    end
  end

  @doc """
  Macro defines the client API and the Callback API of GenServer.

  The following `defcall` macro defines
    `GenServer.call/3` wrapper for Client and
    `GenServer.handl_call/3` server callback to receive `GenServer.call/3` message.

  `state` argument specify current state of GenServer.
  The format that returns `defcall` macro must be the same format that
    returns `GenServer.handl_call/3` callback.

  ## Examples
      defmodule Arithmetic do
        defcast add_op(value1, value2, state) do
          state = put_in(state[:add], value1 + value2)
          {:reply, state.add, state}
        end
      end

      > Arithmetic.add_op(pid, value1 = 1, value2 = 3)

  """
  defmacro defcall(message, _var \\ quote(do: _), do: contents) do
    {func, args} = Macro.decompose_call(message)
    args = Macro.escape(args)
    func = Macro.escape(func)
    pid = Macro.escape(Macro.var(:pid, nil))
    contents = Macro.escape(contents)

    quote bind_quoted: [pid: pid, args: args, func: func, contents: contents] do
      state_name = MinDelegate.get_attribute(__MODULE__, :alias, :state, true)
      args = Enum.filter(args, &(!match?({^state_name, _, _}, &1)))
      state = Macro.var(state_name, nil)

      def unquote(func)(unquote(pid), unquote_splicing(args)) do
        msg = {unquote(func), unquote_splicing(args)}
        GenServer.call(unquote(pid), msg)
      end

      def handle_call({unquote(func), unquote_splicing(args)}, _from, unquote(state)) do
        unquote(contents)
      end
    end
  end

  @doc """
  Macro defines the client API and the Callback API of GenServer.

  The following `defcast` macro defines
    `GenServer.cast/2` wrapper for Client and
    `GenServer.handl_cast/2` server callback to receive `GenServer.cast/2` message

  `state` argument specify current state of GenServer.
  The format that returns `defcast` macro must be the same format that
    returns `GenServer.handl_cast/2` callback.

  ## Examples
      defmodule Arithmetic do
        defcast minus_op(value1, value2, state) do
          state = put_in(state[:minus], value1 - value2)
          {:noreply, state}
        end
      end

      > Arithmetic.minus_op(pid, value1 = 1, value2 = 3)
  """
  defmacro defcast(message, _var \\ quote(do: _), do: contents) do
    {func, args} = Macro.decompose_call(message)
    args = Macro.escape(args)
    func = Macro.escape(func)
    pid = Macro.escape(Macro.var(:pid, nil))
    contents = Macro.escape(contents)

    quote bind_quoted: [pid: pid, args: args, func: func, contents: contents] do
      state_name = MinDelegate.get_attribute(__MODULE__, :alias, :state, true)
      args = Enum.filter(args, &(!match?({^state_name, _, _}, &1)))
      state = Macro.var(state_name, nil)

      def unquote(func)(unquote(pid), unquote_splicing(args)) do
        msg = {unquote(func), unquote_splicing(args)}
        GenServer.cast(unquote(pid), msg)
      end

      def handle_cast({unquote(func), unquote_splicing(args)}, unquote(state)) do
        unquote(contents)
      end
    end
  end

  @doc """
  Macro defines the client API and the Callback API of GenServer.

  The following `definfo` macro defines
    `Kernel.send/2` and `Process.send_after/4` wrapper for Client and
    `GenServer.handl_info/2` server callback to receive `info` message

  `state` argument specify current state of GenServer.
  The format that returns `definfo` macro must be the same format that
    returns `GenServer.handl_info/2` callback.

  ## Examples
      defmodule Arithmetic do
        definfo multiple_op(value1, value2, state) do
          state = put_in(state[:multiple], value1 * value2)
          {:noreply, state}
        end
      end

      > Arithmetic.multiple_op(pid, value1 = 1, value2 = 3)
      > Arithmetic.multiple_op(pid, value1 = 1, value2 = 3, delay = 3000)
  """
  defmacro definfo(message, _var \\ quote(do: _), do: contents) do
    {func, args} = Macro.decompose_call(message)
    args = Macro.escape(args)
    func = Macro.escape(func)
    pid = Macro.escape(Macro.var(:pid, nil))
    contents = Macro.escape(contents)

    quote bind_quoted: [pid: pid, args: args, func: func, contents: contents] do
      state_name = MinDelegate.get_attribute(__MODULE__, :alias, :state, true)
      args = Enum.filter(args, &(!match?({^state_name, _, _}, &1)))
      state = Macro.var(state_name, nil)

      def unquote(func)(unquote(pid), unquote_splicing(args), delay \\ 0) do
        msg = {unquote(func), unquote_splicing(args)}

        if delay > 0 do
          Process.send_after(unquote(pid), msg, delay)
        else
          send(unquote(pid), msg)
        end
      end

      def handle_info({unquote(func), unquote_splicing(args)}, unquote(state)) do
        unquote(contents)
      end
    end
  end

  @doc false
  def get_attribute(mod, key, default, delete?) do
    attr =
      if delete? do
        Module.delete_attribute(mod, key)
      else
        Module.get_attribute(mod, key)
      end

    if attr do
      attr
    else
      default
    end
  end
end
