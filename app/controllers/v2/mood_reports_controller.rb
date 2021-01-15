class V2::MoodReportsController < UserController
  before_action :snake_case_params
  before_action :auth_patient

  def create
    daily_report = DailyReport.create_if_not_exists(@current_user.id, params["date"])
    daily_report.update!(mood_report_params)
    render(json: daily_report, status: :ok)
  end

  private

  def mood_report_params
    params.require([:date, :doing_okay])
    params.permit(:date, :doing_okay, :doing_okay_reason)
  end
end
