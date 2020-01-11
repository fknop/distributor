defmodule DistributorWeb.JobControllerTest do
  use DistributorWeb.ConnCase

  test "Should register the node to a server" do
    conn =
      post(build_conn(), "/jobs", %{
        node_index: 0,
        node_total: 3,
        build_id: "id",
        test_suite: "backend",
        commit_sha: "sha",
        branch: "branch",
        initialize: true,
        api_token: "api_token",
        spec_files: [
          "test.spec.js",
          "test2.spec.js",
          "test3.spec.js"
        ]
      })

    body = json_response(conn, 200)
    assert %{ "spec_files" => ["test.spec.js"]} = body
  end

  test "Should not be able to send spec_files when already initialized" do
    conn =
      post(build_conn(), "/jobs", %{
        node_index: 0,
        node_total: 3,
        build_id: "id-3",
        test_suite: "backend",
        commit_sha: "sha",
        branch: "branch",
        initialize: true,
        api_token: "api_token",
        spec_files: [
          "test.spec.js",
          "test2.spec.js",
          "test3.spec.js"
        ]
      })

    json_response(conn, 200)

    conn =
      post(build_conn(), "/jobs", %{
        node_index: 0,
        node_total: 3,
        build_id: "id-3",
        test_suite: "backend",
        commit_sha: "sha",
        branch: "branch",
        initialize: false,
        api_token: "api_token",
        spec_files: [
          "test.spec.js",
          "test2.spec.js",
          "test3.spec.js"
        ]
      })

    json_response(conn, 400)
  end

  test "Should not be able to not send spec_files on initialization" do
    conn =
      post(build_conn(), "/jobs", %{
        node_index: 0,
        node_total: 3,
        build_id: "id-4",
        test_suite: "backend",
        commit_sha: "sha",
        branch: "branch",
        initialize: true,
        api_token: "api_token"
      })

    json_response(conn, 400)
  end

  test "Should be able to register multiple nodes and requests specs" do
    conn =
      post(build_conn(), "/jobs", %{
        node_index: 0,
        node_total: 3,
        build_id: "id-2",
        test_suite: "backend",
        commit_sha: "sha",
        branch: "branch",
        initialize: true,
        api_token: "api_token",
        spec_files: [
          "test.spec.js",
          "test2.spec.js",
          "test3.spec.js"
        ]
      })

    body = json_response(conn, 200)

    assert %{"spec_files" => ["test.spec.js"]} = body

    conn =
      post(build_conn(), "/jobs", %{
        node_index: 0,
        node_total: 3,
        build_id: "id-2",
        test_suite: "backend",
        commit_sha: "sha",
        branch: "branch",
        initialize: true,
        api_token: "api_token",
        spec_files: [
          "test.spec.js",
          "test2.spec.js",
          "test3.spec.js"
        ]
      })

    body = json_response(conn, 400)
    assert %{"message" => "already_registered"} = body

    conn =
      post(build_conn(), "/jobs", %{
        node_index: 1,
        node_total: 3,
        build_id: "id-2",
        test_suite: "backend",
        commit_sha: "sha",
        branch: "branch",
        initialize: false,
        api_token: "api_token"
      })

    body = json_response(conn, 200)
    assert %{"spec_files" => ["test2.spec.js"]} = body


    conn =
      post(build_conn(), "/jobs", %{
        node_index: 2,
        node_total: 3,
        build_id: "id-2",
        test_suite: "backend",
        commit_sha: "sha",
        branch: "branch",
        initialize: false,
        api_token: "api_token"
      })

    body = json_response(conn, 200)
    assert %{"spec_files" => ["test3.spec.js"]} = body


    conn =
      post(build_conn(), "/jobs", %{
        node_index: 3,
        node_total: 3,
        build_id: "id-2",
        test_suite: "backend",
        commit_sha: "sha",
        branch: "branch",
        initialize: false,
        api_token: "api_token"
      })

    json_response(conn, 400)

    conn =
      post(build_conn(), "/jobs", %{
        node_index: 2,
        node_total: 3,
        build_id: "id-2",
        test_suite: "backend",
        commit_sha: "sha",
        branch: "branch",
        initialize: false,
        api_token: "api_token"
      })

    body = json_response(conn, 200)
    assert %{"spec_files" => []} = body


  end

end
