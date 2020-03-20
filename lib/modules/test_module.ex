defmodule Botler.Modules.TestModule do
  @behaviour Botler.Module

  alias Nostrum.Api

  @impl Botler.Module
  def message(msg) do
    case msg.content do
      "!ping" ->
        Api.create_message!(msg.channel_id, "pong!")
      _ ->
        :ignore
    end
  end
end
