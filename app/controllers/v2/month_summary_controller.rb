class V2::MonthSummaryController < UserController
  before_action :auth_admin

  def index
    month = params[:month].to_i || Time.now.month
    year = params[:year].to_i || Time.now.year
    site = params[:site] || "all"
    
    summary = MonthSummary.new(month, year, site)
    render(json: summary, status: :ok)
  end

end
