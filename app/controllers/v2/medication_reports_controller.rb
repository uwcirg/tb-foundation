class V2::MedicationReportsController < UserController
  before_action :snake_case_params
  before_action :auth_patient

  def create
    daily_report = DailyReport.create_if_not_exists(@current_user.id, params["date"])
    daily_report.update!(medication_report: @current_user.medication_reports.create!(medication_report_params))
    render(json: daily_report, status: :ok)
  end

  private

  def medication_report_params
    params.require([:date,:datetime_taken,:medication_was_taken])
    params.permit(:date,:datetime_taken,:medication_was_taken,:why_medication_not_taken)
  end
end
