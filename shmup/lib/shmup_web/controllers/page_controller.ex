defmodule ShmupWeb.PageController do
  use ShmupWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
