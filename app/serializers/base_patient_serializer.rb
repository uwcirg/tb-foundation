class BasePatientSerializer < ActiveModel::Serializer
  attributes :app_start_date
  attribute :treatment_outcome, if: -> { object.archived? }

  def app_start_date
    object.patient_information.datetime_patient_activated
  end

  def treatment_outcome
    {
          treatment_outcome: object.patient_information.treatment_outcome,
          app_end_date: object.patient_information.app_end_date,
        }
  end
end
