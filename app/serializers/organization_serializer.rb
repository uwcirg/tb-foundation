class OrganizationSerializer < ActiveModel::Serializer
    attributes :title

    has_many :patients, serializer: PatientAnonSerializer
end