class V2::DailyReportController < UserController
  before_action :snake_case_params
  before_action :auth_patient

  def index
    todays_report = @current_user.daily_reports.find_by(find_daily_report_params)
    if (todays_report.nil?)
      render(json: { error: "No report found for #{params[:date]}" }, status: :not_found)
    else
      render(json: todays_report, status: :ok)
    end
  end

  def create
    if (create_params[:no_issues] == "true")
      daily_report = nil
      ActiveRecord::Base.transaction do
        daily_report = DailyReport.create_if_not_exists(@current_user.id, create_params["date"])
        medication_report = @current_user.medication_reports.create!(date: create_params["date"], medication_was_taken: true)
        symptom_report = @current_user.symptom_reports.create!(date: create_params["date"])
        daily_report.update!(was_one_step: true, doing_okay: true, medication_report: medication_report, symptom_report: symptom_report)
      end

      render(json: daily_report, status: :created)
    else
      render(json: { error: "This route only supports reports with no_issues=true, to report issues use individual routes ie. /v2/medication_reports", code: 400 }, status: 400)
    end
  end

  private

  def find_daily_report_params
    params.require(:date)
    params.permit(:date)
  end

  def create_params
    params.require(:date)
    params.require(:no_issues)
    params.permit(:date, :no_issues)
  end
end
