include PolicyHelper

class PatientRecordPolicy < Struct.new(:user, :patient_record)
  
    def index?
    patient_belongs_to_practitioner or user_is_current_patient
  end

  def show?
    patient_belongs_to_practitioner or user_is_current_patient
  end
end
