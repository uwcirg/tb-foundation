class PatientAnonSerializer < ActiveModel::Serializer
    attributes :id, :organization_id, :adherence

    has_many :photo_days do
      object.photo_days.order("date")
    end

  end
  