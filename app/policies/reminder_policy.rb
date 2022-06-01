class ReminderPolicy < ApplicationPolicy
  attr_reader :user, :reminder

  def initialize(user, reminder)
    @user = user
    @reminder = reminder
  end

  def create?
    (@user.patient? && @reminder.patient.id == user.id) || (@user.practitioner? && @reminder.patient.organization_id == user.organization_id)
  end

  def delete?
    (@user.patient? && @reminder.patient.id == user.id) || (@user.practitioner? && @reminder.creator_id == @user.id)
  end
end
