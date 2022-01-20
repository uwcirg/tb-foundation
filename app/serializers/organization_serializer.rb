class OrganizationSerializer < ActiveModel::Serializer
    attributes :title, :id, :symptom_summary, :practitioner_messages_per_patient
    has_many :patients, serializer: AdminPatientSerializer
end