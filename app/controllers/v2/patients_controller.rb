class V2::PatientsController < UserController

    def update
    
        render(json: @current_user, status: :ok)
    
    
    end



end