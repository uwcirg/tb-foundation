class Organization::CohortSummaryController < UserController

    before_action :verify_practitioner

    def index
        render(json: Organization.find(params[:organization_id]).cohort_summary, status: :ok)
    end 

    private

    def verify_practitioner
        auth_practitioner
    
        if(@current_practitoner.organization_id != params[:organization_id].to_i)
            render(json: {error: "You're not authorized to view that organization" }, status: :unauthorized)
            return
        end
    end

  end
  