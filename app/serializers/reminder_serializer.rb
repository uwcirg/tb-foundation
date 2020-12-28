class ReminderSerializer < ActiveModel::Serializer

    attributes :id, :title, :category, :datetime, :note

    def title
        object.other_category
    end


end