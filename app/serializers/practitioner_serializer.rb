class PractitionerSerializer < ActiveModel::Serializer
    attributes :id, :given_name, :family_name, :organization_id
end