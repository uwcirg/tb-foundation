include PolicyHelper

class PhotoReviewPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if @user.admin?
        scope.all
      elsif @user.bio_engineer?
        scope.where(bio_engineer: @user)
      else
        raise Pundit::NotAuthorizedError, "not allowed to view this action"
      end
    end
  end

  attr_reader :user, :review

  def initialize(user, review)
    @user = user
    if(!review.nil?)
      @review = review
    end
  end

  def create?
    @user.bio_engineer?
  end

  def index?
    @user.admin? || @user.bio_engineer?
  end

  def show?
    @user.admin? || @user.bio_engineer?
  end

  def update?
    @user.bio_engineer?
  end
  
end
