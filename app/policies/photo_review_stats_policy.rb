class PhotoReviewStatsPolicy < ApplicationPolicy

    attr_reader :user
  
    def initialize(user, record)
      @user = user
      @record = record
    end

    def show?
        @user.bio_engineer?
    end

  end