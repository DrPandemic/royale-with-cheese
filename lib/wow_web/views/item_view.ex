defmodule WowWeb.ItemView do
  use WowWeb, :view

  def render("show.json", %{entries: entries, item: item}) do
    %{item: item, entries: entries}
  end
end
