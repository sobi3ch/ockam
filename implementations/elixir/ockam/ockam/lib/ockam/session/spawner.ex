defmodule Ockam.Session.Spawner do
  @moduledoc """
  Simple worker spawner which does not track spawned workers

  Options:

  `worker_mod` - worker module to spawn, required
  `worker_opions` - additional options of the spawned worker, defaults to []
  `message_parser` - function parsing init message to a Keyword list, defaults to `&default_message_parser/1`

  Upon receiving a message, `worker_mod` worker will be started
  with options from `worker_options` merged with result of `message_parser`

  Example:

  ```
  ## Given a spawner
  {:ok, spawner} = Ockam.Session.Spawner.create(worker_mod: MyWorker, worker_options: [key: "val"])

  ## Sending init message
  Ockam.Router.route(%{onward_route: [spawner], return_route: ["me"], payload: "HI!"})

  ## Is equivalent to calling:
  MyWorker.create(key: "val", init_message: %{onward_route: [spawner], return_route: ["me"], payload: "HI!"})

  ## If spawner has a custom message parser:
  {:ok, spawner} = Ockam.Session.Spawner.create(worker_mod: MyWorker, message_parser: fn(msg) -> [pl: Ockam.Message.payload(msg)] end)

  ## Sending init message
  Ockam.Router.route(%{onward_route: [spawner], return_route: ["me"], payload: "HI!"})

  ## Is equivalent to calling:
  MyWorker.create(pl: "HI!")
  ```
  """
  use Ockam.Worker

  require Logger

  @impl true
  def address_prefix(_options), do: "SP_"

  @impl true
  def setup(options, state) do
    worker_mod = Keyword.fetch!(options, :worker_mod)
    worker_options = Keyword.get(options, :worker_options, [])
    message_parser = Keyword.get(options, :message_parser, &default_message_parser/1)

    {:ok,
     Map.merge(state, %{
       worker_mod: worker_mod,
       worker_options: worker_options,
       message_parser: message_parser
     })}
  end

  @impl true
  def handle_message(message, state) do
    worker_mod = Map.fetch!(state, :worker_mod)
    worker_options = Map.fetch!(state, :worker_options)

    case maybe_parse_message(message, state) do
      {:ok, result} ->
        ## NOTE: credo has false-positive here without additional variable
        worker_options = Keyword.merge(worker_options, result)
        Logger.info("Worker options: #{inspect(worker_options)}")
        worker_mod.create(worker_options)

      {:error, err} ->
        Logger.error("Invalid init message: #{inspect(message)}, reason: #{inspect(err)}")
    end

    {:ok, state}
  end

  def maybe_parse_message(message, state) do
    message_parser = Map.get(state, :message_parser)
    message_parser.(message)
  end

  def default_message_parser(message) do
    {:ok, [init_message: message]}
  end
end
