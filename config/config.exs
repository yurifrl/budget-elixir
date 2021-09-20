import Config

config :budget, Budget.Nu, adapter: Budget.Nu.Adapters.Http
config :budget, Budget.Nu.Manager, adapter: Budget.Nu.Adapters.Http
config :budget, Budget.Nu.Adapters.Http, base_url: "https://prod-s0-webapp-proxy.nubank.com.br/"
