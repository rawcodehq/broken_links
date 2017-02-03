defmodule BrokenLinks.PageController do
  use BrokenLinks.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  import Logger, only: [debug: 1]
  def analyze(conn, %{"url" => url}) do
    broken_links = if :ets.member(:urls, url) do
      debug("existing url fetching from ets")
      [{_, broken_links}] = :ets.lookup(:urls, url)
      broken_links
    else
      debug("new url insert into ets")
      :ets.insert(:urls, {url, []})
      spawn(BrokenLinks.PageAnalyzer, :analyze, [url])
      []
    end

    render conn, "analyze.html", url: url, broken_links: broken_links

  end
end

