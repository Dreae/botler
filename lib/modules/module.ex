defmodule Botler.Module do
  @callback message(msg :: Nostrum.Struct.Message.t) :: :ok | {:error, term}
  @callback new_user(guild_id :: Integer.t, user :: Nostrum.Struct.Guild.Member.t) :: :ok | {:error, term}
  @callback reaction(args :: Nostrum.Struct.Message.NewReaction.t) :: :ok | {:error, term}
  @callback reaction_removed(args :: Nostrum.Struct.Message.RemovedReaction.t) :: :ok | {:error, term}

  @optional_callbacks message: 1, new_user: 2
  @optional_callbacks reaction: 1, reaction_removed: 1
end
