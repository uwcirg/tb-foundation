class OrganizationPolicy < ApplicationPolicy
    class Scope < Scope
        def resolve
          if  @user.type == "Administrator"
            scope.all
          else
            raise Pundit::NotAuthorizedError, 'not allowed to view this action'
          end
        end
      end

    attr_reader :user, :organization
  
    def initialize(user, organization)
      @user = user
      @organization = organization
    end

    def index?
        user_is_administrator?
    end

    private

  end