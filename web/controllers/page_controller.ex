defmodule BrokenLinks.PageController do
  use BrokenLinks.Web, :controller
  alias BrokenLinks.PageAnalyzer

  def index(conn, _params) do
    render conn, "index.html", links: PageAnalyzer.links, scheduled_sites: Scheduler.scheduled_sites
  end

  import Logger, only: [debug: 1]
  def analyze(conn, %{"url" => url}) do
    PageAnalyzer.nq(url)

    all_links = PageAnalyzer.result_for(url)

    {broken_links_at_root, links} = Enum.split_with(all_links, fn x -> match?(:error, x) end)

    {good_links, broken_links} = Enum.split_with(links, fn %{broken_links: broken_links} -> length(broken_links) == 0 end)
    render conn, "analyze.html", url: url, good_links: good_links, broken_links: broken_links ++ broken_links_at_root
  end

  def create_schedule(conn, %{"url" => url}) do
    Scheduler.add(url)
    redirect conn, to: "/"
  end
end

