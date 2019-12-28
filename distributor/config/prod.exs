import Config

config :distributor, DistributorWeb.Endpoint,
  url: [compress: true, port: 4000],
  server: true

config :libcluster,
  topologies: [
    distributor:
      if System.get_env("DISTRIBUTOR_KUBERNETES") do
        [
          strategy: Elixir.Cluster.Strategy.Kubernetes.DNS,
          config: [
            service: "distributor-nodes",
            application_name: "distributor"
          ]
        ]
      else
        [
          strategy: Elixir.Cluster.Strategy.Gossip
        ]
      end
  ]

# Do not print debug messages in production
config :logger, level: :info
