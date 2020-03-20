defmodule Botler.GuildWorker do
  use GenServer

  def start_link(guild_id) do
    GenServer.start_link(__MODULE__, guild_id)
  end

  def init(guild_id) do
    {:ok, %{guild_id: guild_id, modules: [Botler.Modules.TestModule, Botler.Modules.SmashArenas]}}
  end

  defmacro dispatch(module, func, args) do
    quote do
      if function_exported?(unquote(module), unquote(func), length(unquote(args))) do
        apply(unquote(module), unquote(func), unquote(args))
      end
    end
  end

  def handle_info({:message, msg}, %{modules: modules} = state) do
    for module <- modules, do: dispatch module, :message, [msg]
    {:noreply, state}
  end

  def handle_info({:new_user, {guild_id, member}}, %{modules: modules} = state) do
    for module <- modules, do: dispatch module, :new_user, [guild_id, member]
    {:noreply, state}
  end

  def handle_info({:reaction, reaction}, %{modules: modules} = state) do
    for module <- modules, do: dispatch module, :reaction, [reaction]
    {:noreply, state}
  end

  def handle_info({:reaction_removed, reaction}, %{modules: modules} = state) do
    for module <- modules, do: dispatch module, :reaction_removed, [reaction]
    {:noreply, state}
  end

  def handle_info({:add_module, module}, %{modules: modules} = state) do
    {:noreply, %{state | modules: [module | modules]}}
  end
end
