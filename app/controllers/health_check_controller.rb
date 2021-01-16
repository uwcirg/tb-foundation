class HealthCheckController < ApplicationController
  def index
    basic_query = { 
        "status": "Functional",
        "organizationCount": Organization.all.count, 
        "userCount": User.all.count }
    render(json: basic_query, status: :ok)
  end
end
