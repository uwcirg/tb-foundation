include PolicyHelper

class PatientRecordPolicy < ApplicationPolicy


  class Scope < Scope
    def resolve
      if  @user.admin?
        scope.all
      else
        raise Pundit::NotAuthorizedError, 'not allowed to view this action'
      end
    end
  end

  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
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
