class UnreadMessageSerializer < ActiveModel::Serializer
    attributes :number_unread, :channel_id
end