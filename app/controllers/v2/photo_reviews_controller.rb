class V2::PhotoReviewsController < UserController
  before_action :snake_case_params

  def index
    @photo_reviews = policy_scope(PhotoReview).order("photo_reviews.id DESC").includes(:photo_report, :code_applications, :photo_codes)

    if (params.has_key?(:offset))
      @photo_reviews =  @photo_reviews.offset(params[:offset])
    end

    render(json: @photo_reviews.limit(10), status: :ok)
  end

  def create
    authorize PhotoReview
    new_review = @current_user.photo_reviews.create!(create_params)
    render(json: new_review, status: :created)
  end

  private

  def create_params
    params.require(:photo_review).permit(:photo_report_id, :test_line_review, 
      :control_line_review, :control_color_id, :test_color_id,
      :test_strip_id,:control_color_value, :test_color_value,
      :test_strip_version_id, 
      code_applications_attributes: [:photo_code_id])
  end
end
