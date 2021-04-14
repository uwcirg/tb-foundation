class V2::TrialSummaryController < UserController
  before_action :auth_admin

  def index
    summary = TrialSummary.new
    render(json: summary, status: :ok)
  end

end
