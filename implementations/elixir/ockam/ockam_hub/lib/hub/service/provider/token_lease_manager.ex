defmodule Ockam.TokenLeaseManager.Hub.Service.Provider do
  @moduledoc false
  @behaviour Ockam.Hub.Service.Provider

  @services [:influxdb_token_lease_service]
  @address "influxdb_token_lease_service"

  @impl true
  def services() do
    @services
  end

  @impl true
  def start_service(service_name, args) do
    options = service_options(service_name, args)
    mod = service_mod(service_name)
    mod.create(options)
  end

  @impl true
  def child_spec(service_name, args) do
    options = service_options(service_name, args)
    mod = service_mod(service_name)
    {mod, options}
  end

  def service_mod(_service) do
    Ockam.TokenLeaseManager
  end

  def service_options(_service, _args), do: [address: @address]
end
