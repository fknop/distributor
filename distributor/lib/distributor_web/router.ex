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
      post "/", Controller, :fetch_specs
      get "/", Controller, :fetch_queue
    end

    scope "/record", Job do
      post "/", Controller, :record_queue
    end
  end
end
