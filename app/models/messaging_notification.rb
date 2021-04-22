class MessagingNotification < ApplicationRecord
  validates :user_id, uniqueness: { scope: :channel_id }
  belongs_to :user
  belongs_to :channel
  has_one :message
end
