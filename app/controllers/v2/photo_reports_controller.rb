class V2::PhotoReportsController < UserController
  before_action :snake_case_params
  before_action :auth_patient, except: :index

  def index
    @photo_reports = policy_scope(PhotoReport).joins(:daily_report).order("daily_reports.created_at DESC")
    limit_photo_reports
    render(json: @photo_reports.limit(10), status: :ok)
  end

  def create
    daily_report = DailyReport.create_if_not_exists(@current_user.id, params["date"])
    daily_report.update!(photo_report: @current_user.photo_reports.create!(photo_report_params))
    render(json: daily_report, status: :created)
  end

  private

  def photo_report_params
    #Modify to allow for no photo submission if opt out options are given
    if (params[:photo_was_skipped] == true)
      params.require([:date, :why_photo_was_skipped])
    else
      params.require([:date, :photo_url])
    end

    params.permit(:date, :back_submission, :photo_url, :captured_at, :why_photo_was_skipped, :photo_was_skipped)
  end

  def limit_photo_reports
    if(not params[:before].nil?)
      @photo_reports = @photo_reports.where("daily_reports.created_at < ?", params[:before])
     end
  end

end
