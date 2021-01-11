class V2::PhotoReportsController < UserController
    before_action :snake_case_params
    before_action :auth_patient
  
    def create
        render(json: {message: "Created photo report"}, status: :ok)
    end
end