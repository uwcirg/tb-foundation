class V2::SymptomReportsController < UserController
  before_action :snake_case_params
  before_action :auth_patient

  def create
    daily_report = DailyReport.create_if_not_exists(@current_user.id, params["date"])
    symptom_report = @current_user.symptom_reports.create!(symptom_report_params)
    daily_report.update!(symptom_report: symptom_report)
    notify_providers_of_severe_symptom if symptom_report.has_severe_symptom?
    render(json: daily_report, status: :ok)
  end

  private

  def notify_providers_of_severe_symptom
    ::SevereSymptomsAlertWorker.perform_async(@current_user.organization_id)
  end

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
                  :vertigo,
                  :confusion,
                  :oliguria,
                  :joint_pain,
                  :burning_or_numbness,
                  :flu_symptoms,
                  :red_urine,
                  :sleepy,
                  :dizziness,
                  :headache,
                  :other)
  end
end
