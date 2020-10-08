class MessagingNotification < ApplicationRecord
  validates :user_id, uniqueness: { scope: :channel_id }
  belongs_to :user
  has_one :channel
  has_one :message
end
