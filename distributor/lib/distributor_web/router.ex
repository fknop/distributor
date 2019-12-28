defmodule DistributorWeb.Router do
  use DistributorWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug DistributorWeb.VerifyApiToken
  end

  # Other scopes may use custom stacks.
  scope "/", DistributorWeb do
    pipe_through :api

    scope "/jobs", Job do
      post "/", Controller, :register_job
      get "/:id/spec_files", Controller, :request_spec
    end
  end
end
