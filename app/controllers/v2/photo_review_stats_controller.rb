class V2::PhotoReviewStatsController < UserController
    def show
        stats = PhotoReviewStats.new(@current_user)
        render(json: stats, status: :ok)
    end
end