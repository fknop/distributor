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
      post "/", Controller, :fetch_queue
    end
  end
end
