class ChannelPolicy < ApplicationPolicy
  
  class Scope < Scope

    def resolve
      if @user.type == "Practitioner"
        scope.where(is_private: true, user: @user.patients)
        .or(Channel.where(is_private: true, category: "SiteGroup", organization_id: @user.organization_id ))
        .or(Channel.where(is_private: false)).order(:organization_id, :created_at)
      elsif @user.type == "Patient"
        scope.where(is_private: false).or(Channel.where(is_private: true, user_id: @user.id))
        .or(Channel.where(is_private: true, category: "SiteGroup", organization_id: @user.organization_id ))
        .order(:created_at)
      else
        raise Pundit::NotAuthorizedError, 'not allowed to view this action'
      end
    end
  end
end
