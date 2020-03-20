defmodule Botler.Modules.SmashArenas do
  @behaviour Botler.Module

  alias Nostrum.Api
  alias Nostrum.Permission
  import Nostrum.Struct.Embed

  @impl Botler.Module
  def message(msg) do
    case msg.content do
      <<"!arena", " ", arena_id::binary-5, " ", arena_name::binary>> ->
        overwrites = [%{type: "member", id: msg.author.id, allow: Permission.to_bitset([:manage_channels])}]
        {:ok, category} = Api.create_guild_channel(msg.guild_id, name: "Arena #{arena_id}: #{arena_name}", type: 4)
        {:ok, _} = Api.create_guild_channel(msg.guild_id, name: "Voice Chat", type: 2, parent_id: category.id, permission_overwrites: overwrites)
        {:ok, text_channel} = Api.create_guild_channel(msg.guild_id, name: "Text Chat", type: 0, parent_id: category.id, permission_overwrites: overwrites)

        Api.create_message!(text_channel.id, "<@#{msg.author.id}> this is the channel for your arena. Use `!shutdown` to shutdown your arena when you're done.")

        content =  "#{get_role_mention(msg.guild_id, "Smasher")}<@#{msg.author.id}> has created an online arena, join now!"
        embed = %Nostrum.Struct.Embed{}
          |> put_title("War were declared")
          |> put_field("Arena ID", arena_id, true)
          |> put_field("Arena Name", arena_name, true)
        Api.create_message!(msg.channel_id, content: content, embed: embed)
      <<"!shutdown">> ->
        guild = Nostrum.Cache.GuildCache.get!(msg.guild_id)
        member = Map.get(guild.members, msg.author.id)
        permissions = Nostrum.Struct.Guild.Member.guild_channel_permissions(member, guild, msg.channel_id)

        if Enum.member?(permissions, :manage_channels) do
          current_channel = Api.get_channel!(msg.channel_id)
          for channel <- Api.get_guild_channels!(msg.guild_id), channel.parent_id == current_channel.parent_id, do: Api.delete_channel!(channel.id)
          Api.delete_channel!(current_channel.parent_id)
        else
          Api.create_message!(msg.channel_id, "You do not own this arena, <@#{msg.author.id}>")
        end
      _ ->
        :ignore
    end
    :ok
  end

  defp get_role_mention(guild_id, role_name) do
    guild = Nostrum.Cache.GuildCache.get!(guild_id)

    role = Enum.find(Map.values(guild.roles), &(&1.name == role_name))
    if role do
      "<@&#{role.id}> "
    else
      ""
    end
  end
end
