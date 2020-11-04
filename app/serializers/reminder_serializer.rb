class ReminderSerializer < ActiveModel::Serializer

    attributes :title, :category, :datetime, :note

    def title
        object.other_category
    end


end