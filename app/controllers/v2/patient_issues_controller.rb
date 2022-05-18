class V2::PatientIssuesController < UserController

    before_action :snake_case_params

    def index
        reports_hash = get_hash(DailyReport.where(patient: @current_user.patients).unresolved )
        @patients = policy_scope(Patient).includes(:resolutions,:channels,:patient_information).active
        render(json: @patients, each_serializer: PatientIssueSerializer, reports: reports_hash )
    end

    private 

    def get_hash(report_list)
        report_list.group_by {|r| r.user_id}
    end
end
  