class V2::TrialSummaryController < UserController
  before_action :auth_admin

  def index
    summary = TrialSummary.new
    render(json: summary, status: :ok)
  end

  def get_heatmap
    heatmap = TrialSummary.generate_heatmap_data
    render(json: {heatmap: heatmap}, status: 200)
  end

end
