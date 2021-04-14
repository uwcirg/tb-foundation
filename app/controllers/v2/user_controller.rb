class V2::UserController < UserController

    def index
        render(json: current_user, serializer: UserSerializer, status: :ok)
    end

end