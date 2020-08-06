class PatientNoteSerializer < ActiveModel::Serializer
    attributes :id, :created_at, :patient_id, :note, :title, :practitioner_id
end