class PhotoReportController < UserController
  before_action :auth_admin

  def index
    photo_reports = PhotoReport.all.limit(5).joins(:daily_report).order("daily_reports.created_at DESC")
    render(json: photo_reports, status: 200)
  end
end
