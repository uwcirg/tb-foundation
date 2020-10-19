class Organization::CohortSummaryController < UserController

    before_action :verify_practitioner

    def index
        render(json: Organization.find(params[:organization_id]).cohort_summary, status: :ok)
    end 

    private

  end
  