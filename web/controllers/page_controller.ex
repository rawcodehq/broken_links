defmodule BrokenLinks.PageController do
  use BrokenLinks.Web, :controller
  alias BrokenLinks.PageAnalyzer

  def index(conn, _params) do
    render conn, "index.html", links: PageAnalyzer.links
  end

  import Logger, only: [debug: 1]
  def analyze(conn, %{"url" => url}) do
    PageAnalyzer.nq(url)

    links =  PageAnalyzer.result_for(url)
    {good_links, broken_links} = Enum.split_with(links, fn %{broken_links: broken_links} -> length(broken_links) == 0 end)

    render conn, "analyze.html", url: url, good_links: good_links, broken_links: broken_links
  end
end

