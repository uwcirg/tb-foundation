class V2::PhotoCodesController < UserController
  before_action :snake_case_params

  def index
    render(json: CodeBook.new, status: :ok)
  end

  def create
    render(json: PhotoCode.create!(create_params), status: :created)
  end

  private

  def create_params
    params.require(:photo_code).permit(:photo_code_group_id, :sub_group_code, :description, :title, photo_code_group_attributes: [:id, :group_code, :group])
  end

end
