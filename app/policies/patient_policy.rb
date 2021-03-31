class PatientPolicy < ApplicationPolicy
    attr_reader :user, :patient
  
    def initialize(user, patient)
      @user = user
      @patient = patient
    end
  
    def update?
      user.practitioner?
    end
  end