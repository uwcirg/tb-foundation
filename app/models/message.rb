class Message < ApplicationRecord
    belongs_to :creator, polymorphic: true
    belongs_to :channel
end
