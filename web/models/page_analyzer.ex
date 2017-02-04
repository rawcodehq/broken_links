defmodule BrokenLinks.PageAnalyzer do
  import Logger, only: [debug: 1, error: 1]

  def links do
    :ets.tab2list(:urls) |> Enum.map(fn {k, _} -> k end)
  end

  def nq(url) do
    if :ets.member(:urls, url) do
      debug("existing url fetching from ets")
    else
      debug("new url insert into ets")
      :ets.insert(:urls, {url, []})
      spawn(BrokenLinks.PageAnalyzer, :analyze, [url])
      []
    end
  end

  def broken_links_for(url) do
    case :ets.lookup(:urls, url) do
      [{_, broken_links}] -> broken_links
      _ -> []
    end
  end

  # returns a list of broken urls
  #0. Allow the user to enter a url
  #3. Try to download html for the links from (2)
  #if it fails for a link, it means that link is broken
  def analyze(url) do
    # 1. Download the HTML of the url
    case HTTPoison.get(url, [], [ ssl: [{:versions, [:'tlsv1.2']}] ]) do
      {:ok, %HTTPoison.Response{body: body}} ->
        # 2. Parse out the links from (1)
        links = url |> parse_links(body)
        links |> Enum.each(fn link ->
          # q the internal links
          if internal_link?(url, link.href) do
            nq(link.href)
          end

        end)
        links |> Task.async_stream(fn link ->
          [{_, broken_links}] = :ets.lookup(:urls, url)
          :ets.insert(:urls, {url, [{link, broken_link?(link)} | broken_links]})
        end, max_concurrency: 8)
        |> Enum.to_list

        :ok
      oops ->
        error("ERROR: #{inspect(oops)}")
        :error
    end
  end

  # htttp://minhajuddin.com htttp://minhajuddin.com/about
  defp internal_link?(starting_url, href) do
    URI.parse(starting_url).host == URI.parse(href).host
  end

  defp broken_link?(%{href: href}) do
    debug("checking link: #{inspect href}")
    case HTTPoison.get(href, [], [ ssl: [{:versions, [:'tlsv1.2']}] ]) do
      {:ok, %HTTPoison.Response{status_code: status_code}} -> status_code >= 400
      _ -> true
    end
  end

  # <a href='...'> <span>Foo</span></a>
  defp parse_links(url, html) do
    Floki.find(html, "a")
    |> Enum.map(&extract_link/1)
    |> Enum.filter(& &1)
    |> Enum.map(fn %{href: href} = link ->
      href = url |> URI.parse |> URI.merge(href) |> URI.to_string
      %{link | href: href}
    end)
  end

  defp extract_link({_, attrs, [text]}) do
    case Enum.find(attrs, fn {k, v} -> k == "href" end) do
      {_ , href} -> %{text: text, href: href}
      _ -> nil
    end
  end
  defp extract_link(_), do: nil

end
