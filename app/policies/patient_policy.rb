include PolicyHelper

class PatientPolicy < ApplicationPolicy

  class Scope < Scope
    def resolve
      if  @user.admin?
        scope.all
      elsif @user.practitioner?
        scope.where(organization_id: @user.organization_id)
      else
        raise Pundit::NotAuthorizedError, 'not allowed to view this action'
      end
    end
  end

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

  def activate?
    user_is_current_patient
  end

  def update_treatment_status?
    patient_belongs_to_practitioner
  end


end
