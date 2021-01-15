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
    params.require(:date)
    params.permit(:date, :nausea,
                  :nausea_rating,
                  :redness,
                  :hives,
                  :fever,
                  :appetite_loss,
                  :blurred_vision,
                  :sore_belly,
                  :yellow_coloration,
                  :difficulty_breathing,
                  :facial_swelling,
                  :dizziness,
                  :headache,
                  :other)
  end
end
