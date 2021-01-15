class V2::DailyReportController < UserController
  before_action :snake_case_params
  before_action :auth_patient

  def index
    todays_report = @current_user.daily_reports.find_by(find_daily_report_params)
    if(todays_report.nil?)
      render(json: {error: "No report found for #{params[:date]}"}, status: :not_found)
    else
      render(json: todays_report, status: :ok )
    end
  end

  private

  def find_daily_report_params
    params.require(:date)
    params.permit(:date)
  end
end
