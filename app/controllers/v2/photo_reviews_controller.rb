class V2::PhotoReviewsController < UserController
  before_action :snake_case_params

  def create
    new_review = @current_user.photo_reviews.create!(create_params)
    render(json: new_review, status: :created)
  end

  private

  def create_params
    params.require(:photo_review).permit(:photo_report_id, :test_line_review, 
      :control_line_review, :control_line_color, :test_line_color,
      code_applications_attributes: [:photo_code_id]
    )
  end
end
