class V2::PhotoCodesController < UserController
  def index
    render(json: CodeBook.new, status: :ok)
  end

  def create
    render(json: PhotoCode.create!(create_params), status: :created)
  end

  private

  def create_params
    #params.require([:code,:description,:title])
    params.permit(:code,:description,:title)
  end

end
