import Config

config :budget, env: config_env()

config :budget, Budget.Nu.Adapters.Http,
  username: System.fetch_env!("USERNAME"),
  password: System.fetch_env!("PASSWORD"),
  cert_path: System.fetch_env!("CERT_PATH"),
  key_path: System.fetch_env!("KEY_PATH")
