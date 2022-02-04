include PolicyHelper

class PhotoCodePolicy < ApplicationPolicy
  
  attr_reader :user, :record

  def initialize(user)
    @user = user
  end

  def create?
    @user.bio_engineer?
  end

  def index?
    @user.bio_engineer?
  end

  def show?
    @user.bio_engineer?
  end

  def update?
    @user.bio_engineer?
  end
  
end
