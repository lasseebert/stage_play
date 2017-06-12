defmodule Sample1.Producer do
  @moduledoc """
  A simple set of GenStages with a producer and consumer.

  Producer: Produces numbers
  Consumer: Prints out numbers
  """

  use GenStage

  def start_link do
    GenStage.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    {:producer, 0}
  end

  def handle_demand(demand, counter) when demand > 0 do
    from = counter
    to = counter + demand - 1
    events = Enum.to_list(from..to)
    IO.puts("Producing #{events |> length} numbers: #{events |> Enum.join(", ")}")
    {:noreply, events, to + 1}
  end
end

defmodule Sample1.Consumer do
  use GenStage

  def start_link(producer) do
    GenStage.start_link(__MODULE__, producer)
  end

  def init(producer) do
    {:consumer, nil, subscribe_to: [{producer, max_demand: 10, min_demand: 0}]}
  end

  def handle_events(events, _from, state) do
    IO.puts("Consuming #{events |> length} numbers: #{events |> Enum.join(", ")}")
    :timer.sleep(3000)
    {:noreply, [], state}
  end
end

defmodule Sample1 do
  def start do
    {:ok, producer} = Sample1.Producer.start_link
    {:ok, _consumer} = Sample1.Consumer.start_link(producer)
    :ok
  end
end
