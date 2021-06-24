class MessagePolicy < ApplicationPolicy
  attr_reader :user, :patient

  def initialize(user, message)
    @user = user
    @message = message
  end

  def update?
    @user.practitioner?
  end
end
