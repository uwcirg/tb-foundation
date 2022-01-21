class V2::PhotoCodesController < UserController
  def index
    render(json: PhotoCode.all, status: :ok)
  end
end
