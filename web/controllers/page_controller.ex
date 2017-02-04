defmodule BrokenLinks.PageController do
  use BrokenLinks.Web, :controller
  alias BrokenLinks.PageAnalyzer

  def index(conn, _params) do
    render conn, "index.html"
  end

  import Logger, only: [debug: 1]
  def analyze(conn, %{"url" => url}) do
    PageAnalyzer.nq(url)
    broken_links =  PageAnalyzer.broken_links_for(url)

    render conn, "analyze.html", url: url, broken_links: broken_links
  end
end

