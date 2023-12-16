defmodule Timer do
  def time(label \\ "processing", fun) do
    timestamp = DateTime.now!("Etc/UTC")

    result = fun.()

    IO.puts(
      "#{label} done in #{DateTime.now!("Etc/UTC") |> DateTime.diff(timestamp, :millisecond)}ms"
    )

    result
  end
end
