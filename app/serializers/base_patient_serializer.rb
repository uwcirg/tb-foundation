class BasePatientSerializer < ActiveModel::Serializer
  attributes :status, :id, :organization_id, :adherence, :treatment_start, :days_in_treatment, :app_start_time, :status
  attribute :treatment_outcome, if: -> { object.archived? }

  has_one :contact_tracing_survey do
    @object.contact_tracing_surveys.last
  end

  def treatment_outcome
    {
      treatment_outcome: object.patient_information.treatment_outcome,
      app_end_date: object.patient_information.app_end_date,
    }
  end

  def app_start_time
    object.patient_information.datetime_patient_activated
  end

  def photo_adherence
    object.patient_information.photo_adherence
  end
end
