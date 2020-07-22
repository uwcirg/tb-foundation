class Organization::CohortSummaryController < UserController
    def index
        render(json: Organization.find(params[:organization_id]).cohort_summary, status: :ok)
    end 
  end
  