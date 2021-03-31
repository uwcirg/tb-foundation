class PatientPolicy < ApplicationPolicy
    attr_reader :user, :patient
  
    def initialize(user, patient)
      @user = user
      @patient = patient
    end
  
    def update?
      user.type == "Practitioner" && user.organization_id == patient.organization_id
    end
  end