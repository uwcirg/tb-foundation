class V2::OrganizationsSummaryController < UserController
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    def index
        organizations = policy_scope(Organization).where("id > 0")
        render(json: {message: "okay"}, status: 200)
    end

end