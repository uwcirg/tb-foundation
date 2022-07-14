class ReminderPolicy < ApplicationPolicy
  attr_reader :user, :reminder

  class Scope < Scope
    def resolve
      if user.patient?
        scope.where(patient_id: user.id)
      elsif user.practitioner?
        scope.where(patient: Patient.where(organization_id: user.organization_id))
      else
        raise Pundit::NotAuthorizedError, "This account type cannot view reminders"
      end
    end
  end

  def initialize(user, reminder)
    @user = user
    @reminder = reminder
  end

  def create?
    (@user.patient? && @reminder.patient.id == user.id) || (@user.practitioner? && @reminder.patient.organization_id == user.organization_id)
  end

  def destroy?
    @reminder.creator_id == @user.id
  end
end
