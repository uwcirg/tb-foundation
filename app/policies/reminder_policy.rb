class ReminderPolicy < ApplicationPolicy
    attr_reader :user

    def initialize(user, reminder)
      @user = user
      @reminder = reminder
    end
  
    def create?
      (@user.patient? && reminder.patient.id == user.id)
      || (@user.practitioner? && reminder.patient.organization_id == practitioner.organization_id)
    end

    def delete?
        @user
    end

  end
  