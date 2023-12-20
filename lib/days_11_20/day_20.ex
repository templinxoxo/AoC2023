defmodule Day20 do
  def execute_part_1(data \\ fetch_data()) do
    Timer.time(fn ->
      data
      |> parse_input()
      |> find_cycles()
      |> repeat_button_pushes(1000)
    end)
  end

  def find_cycles(init_modules) do
    {modules, pulse_counter} = process_pulses(init_modules, [{"button", "broadcaster", :low}])

    find_cycles(modules, [pulse_counter], init_modules)
  end

  def find_cycles(modules, pulse_counter_states, init_modules) when modules == init_modules do
    pulse_counter_states
  end


  def find_cycles(modules, pulse_counter_states, init_modules) when length(pulse_counter_states) == 1000 do
    pulse_counter_states
  end

  def find_cycles(modules, pulse_counter_states, init_modules) do
    {modules, pulse_counter} = process_pulses(modules, [{"button", "broadcaster", :low}])
    find_cycles(modules, pulse_counter_states ++ [pulse_counter], init_modules)
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

  def process_pulses(modules, [], pulse_counter), do: {modules, pulse_counter}

  def process_pulses(
        modules,
        [{parent_module_name, module_name, pulse} | remaining_pulses],
        pulse_counter \\ %{}
      ) do
    pulse_counter = Map.update(pulse_counter, pulse, 1, &(&1 + 1))

    case Map.get(modules, module_name) do
      nil ->
        process_pulses(modules, remaining_pulses, pulse_counter)

      module ->
        {module, new_pulses} = process_pulse(module_name, module, parent_module_name, pulse)

        modules = Map.put(modules, module_name, module)

        process_pulses(modules, remaining_pulses ++ new_pulses, pulse_counter)
    end
  end

  # no change to module, pass pulse to destinations
  def process_pulse(module_name, {:broadcaster, destinations} = module, _, pulse) do
    {module, Enum.map(destinations, &{module_name, &1, pulse})}
  end

  # change modules input value for parent_module, pass pulse to destinations based on cached input values
  def process_pulse(module_name, {:conjunction, inputs, destinations}, parent_module, pulse) do
    new_inputs = Map.put(inputs, parent_module, pulse)
    new_module = {:conjunction, new_inputs, destinations}
    new_pulse = if Enum.all?(new_inputs, fn {_, p} -> p == :high end), do: :low, else: :high
    {new_module, Enum.map(destinations, &{module_name, &1, new_pulse})}
  end

  # nothing happens for high pulse
  def process_pulse(_module_name, {:flip_flop, _, _destinations} = module, _, :high) do
    {module, []}
  end

  # flip module state and send pulses for low pulse
  def process_pulse(module_name, {:flip_flop, :off, destinations}, _, :low) do
    {{:flip_flop, :on, destinations}, Enum.map(destinations, &{module_name, &1, :high})}
  end

  def process_pulse(module_name, {:flip_flop, :on, destinations}, _, :low) do
    {{:flip_flop, :off, destinations}, Enum.map(destinations, &{module_name, &1, :low})}
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
        {module_name, {_, _, module_destinations}} -> name in module_destinations
        {module_name, {_, module_destinations}} -> name in module_destinations
      end)
      |> Enum.map(fn {module_name, _} -> {module_name, :low} end)
      |> Map.new()

    {name, {:conjunction, inputs, destinations}}
  end

  def map_inputs_for_conjunctions(module, _modules), do: module
end
