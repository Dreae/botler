defmodule Botler.GuildManager do
  use GenServer
  require Logger

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: Botler.Guilds)
  end

  def init(_opts) do
    Process.flag(:trap_exit, true)
    {:ok, %{guilds: []}}
  end

  def handle_cast({:guild_event, {guild_id, event}}, %{guilds: guilds} = state) do
    case Enum.find(guilds, &(elem(&1, 1) == guild_id)) do
      {guild_worker, _} ->
        send guild_worker, event
      _ ->
        :ignore
    end

    {:noreply, state}
  end

  def handle_cast({:new_guild, guild_id}, %{guilds: guilds} = state) do
    Logger.info("Starting GuildWorker for #{guild_id}")
    {:ok, child} = DynamicSupervisor.start_child(Botler.GuildSupervisor, {Botler.GuildWorker, guild_id})
    Process.link(child)

    {:noreply, %{state | guilds: [{child, guild_id} | guilds]}}
  end

  def handle_info({:EXIT, from, _reason}, %{guilds: guilds} = state) do
    Logger.error("Unexpected guild exit")

    {_, guild_id} = Enum.find(guilds, &(elem(&1, 0) == from))
    GenServer.cast(Botler.Guilds, {:new_guild, guild_id})

    {:noreply, %{state | guilds: Enum.filter(guilds, &(elem(&1, 0) != from))}}
  end
end
