class V2::SymptomReportsController < UserController
    before_action :snake_case_params
    before_action :auth_patient
  
    def create
        daily_report = DailyReport.create_if_not_exists(@current_user.id, params["date"])
        daily_report.update!(symptom_report: @current_user.symptom_reports.create!(symptom_report_params))
        render(json: daily_report, status: :ok)
      end
    
      private
    
      def symptom_report_params
        params.permit(:why_medication_not_taken,:date, :medication_was_taken, :datetime_taken)
      end

end