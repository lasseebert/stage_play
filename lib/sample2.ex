defmodule Sample2.Dice do
  use GenStage

  def start_link(size) do
    GenStage.start_link(__MODULE__, size)
  end

  def init(size) do
    {:producer, size}
  end

  def handle_demand(demand, size) when demand > 0 do
    :timer.sleep(2_000)
    rolls = for _ <- 1..demand, do: :rand.uniform(size)
    {:noreply, rolls, size}
  end
end

defmodule Sample2.Adder do
  use GenStage

  def start_link do
    GenStage.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    {:consumer, nil}
  end

  def handle_events(events, _from, state) do
    IO.puts("Consuming #{events |> length} numbers: #{events |> Enum.join(", ")}")
    {:noreply, [], state}
  end
end

defmodule Sample2 do
  def start do
    {:ok, d6} = Sample2.Dice.start_link(6)
    {:ok, d20} = Sample2.Dice.start_link(20)
    {:ok, adder} = Sample2.Adder.start_link

    GenStage.sync_subscribe(adder, to: d6, index: 0)
    GenStage.sync_subscribe(adder, to: d20, index: 1)

    :ok
  end
end
