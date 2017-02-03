defmodule BrokenLinks.PageController do
  use BrokenLinks.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def analyze(conn, %{"url" => url}) do
    case BrokenLinks.PageAnalyzer.analyze(url) do
      {:ok, broken_links} ->
        render conn, "analyze.html", url: url, broken_links: broken_links
      {:error, message} ->
        text conn, message
    end
  end
end
