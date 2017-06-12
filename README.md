# Genstage - what is it?

Like a pipe operator (`|>`), but for processes and with back pressure and on coke.

So what is this back-pressure? In short it is "pull" and not "push".

## Can I haz some codez?

Sample1 demo

* Show it
* Multiple consumers
* min_demand and max_demand

## Flow

Flow is an independent hex package that builds on top of GenStage.

Use it to create GenStage flows from functions.

Idiomatic example: We want to count each different word in a text file.

### With Enum:

```elixir
File.stream!("path/to/some/file")
|> Enum.flat_map(&String.split(&1, " "))
|> Enum.reduce(%{}, fn word, acc ->
  Map.update(acc, word, 1, & &1 + 1)
end)
|> Enum.to_list()
```

This will build a list of all words in-memory :(

### With Stream:

```elixir
File.stream!("path/to/some/file")
|> Stream.flat_map(&String.split(&1, " "))
|> Enum.reduce(%{}, fn word, acc ->
  Map.update(acc, word, 1, & &1 + 1)
end)
|> Enum.to_list()
```

Will only keep one line in memory, but runs in a single process.

### With Flow:

```elixir
File.stream!("path/to/some/file")
|> Flow.from_enumerable()
|> Flow.flat_map(&String.split(&1, " "))
|> Flow.partition()
|> Flow.reduce(fn -> %{} end, fn word, acc ->
  Map.update(acc, word, 1, & &1 + 1)
end)
|> Enum.to_list()
```

This is shorthand for writing these stages (drawn for two cores):

```
 [file stream]  # Flow.from_enumerable/1 (producer)
    |    |
  [M1]  [M2]    # Flow.flat_map/2 (producer-consumer)
    |\  /|
    | \/ |
    |/ \ |
  [R1]  [R2]    # Flow.reduce/3 (consumer)
```

Notice the `partition`

## BroadcastDispatcher

* As opposed to the default DemandDispatcher.
* Accumulates demand from all consumers and broadcasts all events to each one.
* Each consumer can specify on subscription a `selector` function to only get some specific events. (There goes Hub?)

## Multiple producers

It's possible for a consumer to subscribe to multiple producers, even of different types.

Example: Adding dice from different sources.

```
 [d6]  [d20]
   \     /
    \   /
     \ /
   [adder]
```

In this case it is up to the adder to sync the two streams and add back pressure as needed.
