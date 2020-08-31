class Practitioner::PractitionersController < UserController
    before_action :snake_case_params
    before_action :auth_admin
  
    def index
        
    end

  
  end
  