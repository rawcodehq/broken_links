defmodule Scheduler do
  # TODO: make this persistent storage
  def add(url) do
    :ets.insert(:scheduled_sites, {url, :monthly})
  end

  def scheduled_sites do
    :ets.tab2list(:scheduled_sites)
  end

  # Triggering node
  def trigger_scheduled_sites_check do
    Node.spawn(:blweb@evz, Scheduler, :check_scheduled_sites, [])
  end

  # Web node
  def check_scheduled_sites do
    IO.puts "checking all sites"
    Enum.each(scheduled_sites, fn {url, _schedule} ->
      IO.puts("checking site: #{url}")
      BrokenLinks.PageAnalyzer.nq(url)
    end)
  end

end
