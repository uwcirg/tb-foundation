class HealthCheckController < ApplicationController
  def index
    render(json: HealthCheck.new, status: :ok)
  end
end
