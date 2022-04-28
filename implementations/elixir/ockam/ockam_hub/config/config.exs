## Application configuration used in release as sys.config or mix run
## THIS CONFIGURATION IS NOT LOADED IF THE APP IS LOADED AS A DEPENDENCY

import Config

config :logger, level: :info

config :logger, :console, metadata: [:module, :line, :pid]

import_config "#{Mix.env()}.exs"
