defmodule ShmupWeb.GameLiveTest do
  use ShmupWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders splash with BẮT ĐẦU", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")
    assert render(view) =~ "BẮT ĐẦU"
    assert render(view) =~ "Shmup"
  end

  test "start transitions to playing", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")
    view |> element("button", "BẮT ĐẦU") |> render_click()
    assert render(view) =~ "game-canvas"
  end
end
