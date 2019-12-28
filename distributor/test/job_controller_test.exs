defmodule DistributorWeb.JobControllerTest do
  use DistributorWeb.ConnCase

  test "Should register the node to a server" do
    conn = post(build_conn(), "/jobs", %{
      node_index: 0,
      node_total: 3,
      build_id: "id",
      test_suite: "backend",
      spec_files: [
        "test.spec.js",
        "test2.spec.js",
        "test3.spec.js"
      ]
    })

    body = json_response(conn, 200)
    assert %{"message" => "success"} = body
  end

  test "Should be able to register multiple nodes and requests specs" do
    conn = post(build_conn(), "/jobs", %{
      node_index: 0,
      node_total: 3,
      build_id: "id-2",
      test_suite: "backend",
      spec_files: [
        "test.spec.js",
        "test2.spec.js",
        "test3.spec.js"
      ]
    })

    body = json_response(conn, 200)
    assert %{"message" => "success"} = body

    conn = post(build_conn(), "/jobs", %{
      node_index: 0,
      node_total: 3,
      build_id: "id-2",
      test_suite: "backend",
      spec_files: [
        "test.spec.js",
        "test2.spec.js",
        "test3.spec.js"
      ]
    })

    body = json_response(conn, 400)
    assert %{"message" => "already_registered"} = body

    conn = post(build_conn(), "/jobs", %{
      node_index: 1,
      node_total: 3,
      build_id: "id-2",
      test_suite: "backend",
      spec_files: [
        "test.spec.js",
        "test2.spec.js",
        "test3.spec.js"
      ]
    })

    body = json_response(conn, 200)
    assert %{"message" => "success"} = body

    conn = post(build_conn(), "/jobs", %{
      node_index: 2,
      node_total: 3,
      build_id: "id-2",
      test_suite: "backend",
      spec_files: [
        "test.spec.js",
        "test2.spec.js",
        "test3.spec.js"
      ]
    })

    body = json_response(conn, 200)
    assert %{"message" => "success"} = body

    conn = post(build_conn(), "/jobs", %{
      node_index: 4,
      node_total: 3,
      build_id: "id-2",
      test_suite: "backend",
      spec_files: [
        "test.spec.js",
        "test2.spec.js",
        "test3.spec.js"
      ]
    })

    json_response(conn, 400)


    # REQUESTING SPECS

    conn = get(build_conn(), "/jobs/id-2/spec_files")
    body = json_response(conn, 200)
    assert %{ "spec_files" => ["test.spec.js"] } = body

    conn = get(build_conn(), "/jobs/id-2/spec_files")
    body = json_response(conn, 200)
    assert %{ "spec_files" => ["test2.spec.js"] } = body

    conn = get(build_conn(), "/jobs/id-2/spec_files")
    body = json_response(conn, 200)
    assert %{ "spec_files" => ["test3.spec.js"] } = body

    conn = get(build_conn(), "/jobs/id-2/spec_files")
    body = json_response(conn, 200)
    assert %{ "spec_files" => [] } = body
  end
end
