class V2::OrganizationsController < UserController
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    def index
        organizations = policy_scope(Organization).where("id > 0")
        render(json: organizations, status: :ok)
    end 

    private

    def user_not_authorized
        render(json: { error: "You are not authorized to access details about organizations", code: 401 }, status: 401)
    end

  end
  