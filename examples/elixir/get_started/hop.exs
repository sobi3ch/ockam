defmodule Hop do
  use Ockam.Worker

  alias Ockam.Message
  alias Ockam.Router

  @impl true
  def handle_message(message, %{address: address} = state) do
    IO.puts("Address: #{address}\t Received: #{inspect(message)}")

    ## Forward mesage to the next address and trace current address
    ## in return route.
    forwarded_message = Message.forward_trace(message, address)

    Router.route(forwarded_message)

    {:ok, state}
  end
end
