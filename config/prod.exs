import Config

config :distributor, DistributorWeb.Endpoint,
  url: [compress: true, port: 80],
  server: true

config :libcluster,
  topologies: [
    distributor: [
      strategy: Elixir.Cluster.Strategy.Kubernetes.DNS,
      config: [
        service: "distributor-nodes",
        application_name: "distributor"
      ]
    ]
  ]

# Do not print debug messages in production
config :logger, level: :info
