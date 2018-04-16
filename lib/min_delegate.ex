defmodule MinDelegate do
  @moduledoc """
  Documentation for MinDelegate.
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
    { :noreply, [value | state] }
  end

  # def whereis(id) do
  #   Registry.lookup(:min_delegate_app, id)
  # end
end
