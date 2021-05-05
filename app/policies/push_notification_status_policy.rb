class PushNotificationStatusPolicy < ApplicationPolicy

    def initialize(user, status)
      @user = user
      @status = status
    end
  
    def update?
      user_owns_record
    end
  
    private
  
    def user_owns_record
      @status.user_id == @user.id
    end
  
  end
  