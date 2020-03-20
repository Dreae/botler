defmodule Botler.Worker do
  use Nostrum.Consumer
  require Logger

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}),
    do: GenServer.cast(Botler.Guilds, {:guild_event, {msg.guild_id, {:message, msg}}})

  def handle_event({:GUILD_MEMBER_ADD, {guild_id, _} = info, _ws_state}),
    do: GenServer.cast(Botler.Guilds, {:guild_event, {guild_id, {:new_user, info}}})

  def handle_event({:MESSAGE_REACTION_ADD, reaction, _ws_state}),
    do: GenServer.cast(Botler.Guilds, {:guild_event, {reaction.guild_id, {:reaction, reaction}}})

  def handle_event({:MESSAGE_REACTION_REMOVE, reaction, _ws_state}),
    do: GenServer.cast(Botler.Guilds, {:guild_event, {reaction.guild_id, {:reaction_removed, reaction}}})

  def handle_event({:GUILD_AVAILABLE, {guild}, _ws_state}), do: GenServer.cast(Botler.Guilds, {:new_guild, guild.id})


  def handle_event(_) do

  end
end
