defmodule Api do
  use Tesla
  use Memoize

  plug(Tesla.Middleware.BaseUrl, "https://adventofcode.com/2023/day/")

  plug(Tesla.Middleware.Headers, [
    {"cookie", "session=#{session_cookie()}}"}
  ])

  def session_cookie do
    System.get_env("AOC_SESSION_COOKIE")
  end

  defmemo get_input(day) do
    {:ok, response} = get("#{day}/input")
    response.body
  end
end
