class Organization::OrganizationsController < UserController

    before_action :auth_admin

    def index
        render(json: Organization.all, status: :ok)
    end 

    private

  end
  