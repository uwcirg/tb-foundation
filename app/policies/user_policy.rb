include PolicyHelper

class UserPolicy < ApplicationPolicy

  attr_reader :user, :accessing_user

  def initialize(user, accessing_user)
    @user = user
    @accessing_user = accessing_user
  end

  def update?
    @user.id == @accessing_user.id
  end

end