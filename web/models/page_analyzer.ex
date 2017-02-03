defmodule BrokenLinks.PageAnalyzer do
  # returns a list of broken urls
  #0. Allow the user to enter a url
  #3. Try to download html for the links from (2)
  #if it fails for a link, it means that link is broken
  def analyze(url) do
    # 1. Download the HTML of the url
    case HTTPoison.get(url, [], [ ssl: [{:versions, [:'tlsv1.2']}] ]) do
      {:ok, %HTTPoison.Response{body: body}} ->
        # 2. Parse out the links from (1)
        links = parse_links(url, body)
        broken_links = Enum.filter(links, &broken_link?/1)

        {:ok, broken_links}
      oops ->
        {:error, inspect(oops)}
    end
  end

  import Logger, only: [debug: 1]
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
