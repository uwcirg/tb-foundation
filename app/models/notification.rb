class Notification < ApplicationRecord
    belongs_to :user
    has_one :channel
    has_one :message
  end
  