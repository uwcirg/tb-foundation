class V2::MonthSummaryController < UserController
  before_action :auth_admin

  def index
    from = params[:from] || Time.now - 1.month
    to = params[:to] || Time.now - 1.day
    
    summary = MonthSummary.new(from, to)
    render(json: summary, status: :ok)
  end

end
