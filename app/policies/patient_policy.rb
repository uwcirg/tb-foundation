include PolicyHelper

class PatientPolicy < ApplicationPolicy
  attr_reader :user, :patient

  def initialize(user, patient)
    @user = user
    @patient = patient
  end

  def update?
    patient_belongs_to_practitioner
  end

  def show?
    patient_belongs_to_practitioner or user_is_current_patient
  end


end
