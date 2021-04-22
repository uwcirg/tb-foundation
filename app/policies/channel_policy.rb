class ChannelPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if @user.type == "Practitioner"
        scope.joins(:user)
        .where(is_private: true, users: { organization_id: @user.organization_id , type: "Patient" })
        .or(Channel.joins(:user).where(is_private: true, category: "SiteGroup", organization_id: @user.organization_id ))
        .or(Channel.joins(:user).where(is_private: false)).order(:organization_id, :created_at)
      elsif @user.type == "Patient"
        scope.where(is_private: false).or(Channel.where(is_private: true, user_id: @user.id))
        .or(Channel.where(is_private: true, category: "SiteGroup", organization_id: @user.organization_id ))
        .order(:created_at)
      else
        return Model.none 
      end
    end
  end
end
