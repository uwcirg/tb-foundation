class V2::PhotoReviewStatsController < UserController
    def show
        authorize PhotoReviewStats
        stats = PhotoReviewStats.new(@current_user)
        render(json: stats, status: :ok)
    end
end