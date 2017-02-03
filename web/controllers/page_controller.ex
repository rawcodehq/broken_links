defmodule BrokenLinks.PageController do
  use BrokenLinks.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
