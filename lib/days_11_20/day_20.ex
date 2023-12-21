defmodule Day20 do
  def execute_part_1(data \\ fetch_data()) do
    data
    |> parse_input()
    |> find_cycles(1000)
    |> repeat_button_pushes(1000)
  end

  def execute_part_2(data \\ fetch_data()) do
    data
    |> parse_input()
    |> find_cycles(30_000)

    :ok
  end

  def find_cycles(init_modules, max_cycles) do
    {modules, pulse_counter} = process_pulses(init_modules, [{"button", "broadcaster", :low}], 0)

    find_cycles(modules, [pulse_counter], init_modules, max_cycles)
  end

  def find_cycles(modules, pulse_counter_states, init_modules, _max_cycles)
      when modules == init_modules do
    pulse_counter_states
  end

  def find_cycles(_modules, pulse_counter_states, _init_modules, max_cycles)
      when length(pulse_counter_states) == max_cycles do
    pulse_counter_states
  end

  def find_cycles(modules, pulse_counter_states, init_modules, max_cycles) do
    {modules, pulse_counter} =
      process_pulses(modules, [{"button", "broadcaster", :low}], length(pulse_counter_states))

    find_cycles(modules, pulse_counter_states ++ [pulse_counter], init_modules, max_cycles)
  end

  def repeat_button_pushes(pulse_counter_states, pushes) do
    cycle_length = length(pulse_counter_states)
    full_cycles = floor(pushes / cycle_length)
    incomplete_cycle = rem(pushes, cycle_length)

    {low_fc, high_fc} = calculate_pulses(pulse_counter_states, full_cycles)
    {low_ic, high_ic} = pulse_counter_states |> Enum.take(incomplete_cycle) |> calculate_pulses()
    (low_fc + low_ic) * (high_fc + high_ic)
  end

  def calculate_pulses(pulse_counter_states, cycles \\ 1) do
    %{low: low, high: high} =
      Enum.reduce(
        pulse_counter_states,
        %{low: 0, high: 0},
        &%{low: &1.low + &2.low, high: &1.high + &2.high}
      )

    {cycles * low, cycles * high}
  end

  def process_pulses(modules, pulses, pulse_counter \\ %{}, button_press_counter)

  def process_pulses(modules, [], pulse_counter, _button_press_counter),
    do: {modules, pulse_counter}

  def process_pulses(
        modules,
        [{parent_module_name, module_name, pulse} | remaining_pulses],
        pulse_counter,
        button_press_counter
      ) do
    pulse_counter = Map.update(pulse_counter, pulse, 1, &(&1 + 1))

    case Map.get(modules, module_name) do
      nil ->
        process_pulses(modules, remaining_pulses, pulse_counter)

      module ->
        {module, new_pulse} = process_pulse(module, parent_module_name, pulse)
        do_some_magic(module_name, new_pulse, button_press_counter)

        new_pulses =
          case new_pulse do
            nil -> []
            _ -> module |> get_destinations() |> Enum.map(&{module_name, &1, new_pulse})
          end

        modules = Map.put(modules, module_name, module)

        process_pulses(
          modules,
          remaining_pulses ++ new_pulses,
          pulse_counter,
          button_press_counter
        )
    end
  end

  def get_destinations({:broadcaster, destinations}), do: destinations
  def get_destinations({_type, _, destinations}), do: destinations

  # no change to module, pass pulse to destinations
  def process_pulse({:broadcaster, _destinations} = module, _, pulse) do
    {module, pulse}
  end

  # change modules input value for parent_module, pass pulse to destinations based on cached input values
  def process_pulse({:conjunction, inputs, destinations}, parent_module, pulse) do
    new_inputs = Map.put(inputs, parent_module, pulse)
    new_module = {:conjunction, new_inputs, destinations}
    new_pulse = if Enum.all?(new_inputs, fn {_, p} -> p == :high end), do: :low, else: :high
    {new_module, new_pulse}
  end

  # nothing happens for high pulse
  def process_pulse({:flip_flop, _, _destinations} = module, _, :high) do
    {module, nil}
  end

  # flip module state and send pulses for low pulse
  def process_pulse({:flip_flop, :off, destinations}, _, :low) do
    {{:flip_flop, :on, destinations}, :high}
  end

  def process_pulse({:flip_flop, :on, destinations}, _, :low) do
    {{:flip_flop, :off, destinations}, :low}
  end

  # helpers
  def fetch_data() do
    Api.get_input(20)
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_module/1)
    |> then(fn modules ->
      Enum.map(modules, &map_inputs_for_conjunctions(&1, modules))
    end)
    |> Map.new()
    |> Map.put("button", {:broadcaster, ["broadcaster"]})
  end

  def parse_module(raw_module) do
    [name, raw_destinations] = String.split(raw_module, " -> ", trim: true)
    destinations = String.split(raw_destinations, ", ", trim: true)

    case name do
      "%" <> name -> {name, {:flip_flop, :off, destinations}}
      "&" <> name -> {name, {:conjunction, [], destinations}}
      "broadcaster" -> {name, {:broadcaster, destinations}}
    end
  end

  def map_inputs_for_conjunctions({name, {:conjunction, [], destinations}}, modules) do
    inputs =
      modules
      |> Enum.filter(fn
        {_module_name, {_, _, module_destinations}} -> name in module_destinations
        {_module_name, {_, module_destinations}} -> name in module_destinations
      end)
      |> Enum.map(fn {module_name, _} -> {module_name, :low} end)
      |> Map.new()

    {name, {:conjunction, inputs, destinations}}
  end

  def map_inputs_for_conjunctions(module, _modules), do: module

  # do some magic instead of implementing a proper solution for part 2
  # the 'rx' output is based on previous & and its input of 4 previous pulses
  # if rx expects a low pulse, prev & module will have to receive 4 high pulses from it's inputs
  # to solve this, simply get cycles from all 4 previous modules ->
  #   in this case, print whenever those return high and manually search for cycle
  #   then with those cycles -> LCM will be the final result
  # I also don't see the point of implementing it since I already did that in day8
  def do_some_magic(module, :high, cycle) when module in ["gc", "sz", "cm", "xf"],
    do: IO.puts("#{module}: #{cycle}")

  def do_some_magic(_, _, _), do: nil
end
