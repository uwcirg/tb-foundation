class V2::TimeSummaryController < UserController
    before_action :auth_admin
  
    def index
      n_days = (params[:length].to_i > 0) ? params[:length].to_i  : nil
      summary = TimeSummary.new(n_days)
      render(json: summary, status: :ok)
    end
  
  end
  