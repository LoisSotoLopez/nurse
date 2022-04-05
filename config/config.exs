# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Configures the endpoint
config :nurse, NurseWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "uog+Ej3g4akcu6lAFyMpyO12GQ5pkoH8p7iWrm0Dgc2P30NYMgz8lilXyZDYldd1",
  render_errors: [view: NurseWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Nurse.PubSub,
  live_view: [signing_salt: "9R0Ih2eC"]

config :nurse, :logger, [
  {:handler, :default, :logger_disk_log_h,
   %{
     level: :info,
     config: %{
       file: './log/nurse',
       max_no_bytes: 10_585_760,
       max_no_files: 5
     },
     filters: [
       {:eq_info_filter, {&:logger_filters.domain/2, {:stop, :equal, [:workers]}}}
     ],
     filter_default: :log,
     formatter: {:logger_formatter, %{}}
   }},
  {:handler, :workers, :logger_disk_log_h,
   %{
     level: :info,
     config: %{
       file: './log/nurse_workers',
       max_no_bytes: 10_585_760,
       max_no_files: 5
     },
     filters: [
       {:eq_info_filter, {&:logger_filters.domain/2, {:stop, :not_equal, [:workers]}}}
     ],
     filter_default: :log,
     formatter: {:logger_formatter, %{}}
   }}
]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
