class HealthCheckController < ApplicationController

  def index
    health_check = HealthCheck.new
    render(
      json: health_check, 
      status: health_check.status ? :ok : :internal_server_error,
      content_type: "application/health+json")
  end

end
