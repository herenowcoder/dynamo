Code.require_file "../../../test_helper", __FILE__

defmodule Dynamo.Cowboy.RouterTest do
  use ExUnit.Case, async: true

  defmodule RouterApp do
    use Dynamo.Router

    get "/foo/bar" do
      conn.reply(200, [], "Hello World!")
    end

    get "/mounted" do
      conn.reply(200, [], conn.path_info)
    end

    forward "/baz", to: __MODULE__
  end

  def setup_all do
    Dynamo.Cowboy.run RouterApp, port: 8012, verbose: false
  end

  def teardown_all do
    Dynamo.Cowboy.shutdown RouterApp
  end

  test "basic request on a router app" do
    assert { 200, _, "Hello World!" } = request :get, "/foo/bar"
  end

  test "basic request on a mounted app" do
    assert { 200, _, "/mounted" } = request :get, "/baz/mounted"
  end

  test "404 response a router app" do
    assert { 404, _, "" } = request :get, "/other"
  end

  defp request(verb, path) do
    { :ok, status, headers, client } =
      :hackney.request(verb, "http://127.0.0.1:8012" <> path, [], "", [])
    { :ok, body, _ } = :hackney.body(client)
    { status, headers, body }
  end
end

