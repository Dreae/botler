defmodule Botler do
  use Application
  def start(_type, _args) do
    start()
  end

  def start do
    import Supervisor.Spec

    children = [
      {DynamicSupervisor, strategy: :one_for_one, name: Botler.GuildSupervisor},
      Botler.GuildManager
    ]

    # List comprehension creates a consumer per cpu core
    children = children ++ for i <- 1..System.schedulers_online, do: worker(Botler.Worker, [], id: i)

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
