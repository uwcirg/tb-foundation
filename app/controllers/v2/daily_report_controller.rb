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

  def create
    
  end

  private

  def find_daily_report_params
    params.require(:date)
    params.permit(:date)
  end

  def create_daily_report_params
    params.require(:date)
    params.permit( :date,
    :nausea,:nausea_rating,:redness,
    :hives, :fever, :appetite_loss,
    :blurred_vision, :sore_belly,
    :yellow_coloration, :difficulty_breathing,
    :facial_swelling, :dizziness, :headache,
    :other, :photo_url, :captured_at, :doing_okay, :doing_okay_reason,
    :datetime_taken,:medication_was_taken,:why_medication_not_taken )

  end

end
