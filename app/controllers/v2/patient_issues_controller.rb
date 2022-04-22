class V2::PatientIssuesController < UserController

    before_action :snake_case_params

    def index
        @patients = policy_scope(Patient).includes(:resolutions,:channels,:patient_information)
        render(json: @patients, each_serializer: PatientIssueSerializer )
    end

end
  