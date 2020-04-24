class UnreadMessage < ApplicationRecord
    belongs_to :user
    has_one :channel
    has_one :message


    def numbers_json(*args)
      json = {
        channelID: self.channel_id,
        number: self.number_unread
      }

    end
  end
  