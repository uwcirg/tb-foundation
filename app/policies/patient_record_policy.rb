include PolicyHelper

class PatientRecordPolicy < ApplicationPolicy

  class Scope < Scope
    def resolve
      if  @user.admin?
        scope.all
      elsif @user.practitioner?
        scope.where(patient: Patient.where(organization_id: @user.organization_id ))
      elsif @user.patient?
        scope.where(patient_id: @user.id)
      else
        raise Pundit::NotAuthorizedError, 'not allowed to view this action'
      end
    end
  end

  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
    @patient = record.patient
  end

  def create?
    user_is_current_patient
  end

  def index?
    patient_belongs_to_practitioner or user_is_current_patient
  end

  def show?
    patient_belongs_to_practitioner or user_is_current_patient
  end
end
