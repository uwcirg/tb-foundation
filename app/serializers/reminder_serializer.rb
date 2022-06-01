class ReminderSerializer < ActiveModel::Serializer

    attributes :id, :title, :category, :datetime, :note, :creator_id, :patient_id

    def title
        object.other_category
    end


end