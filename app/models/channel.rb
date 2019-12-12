class Channel < ApplicationRecord
    has_many :messages
    belongs_to :creator, polymorphic: true

    validates :title, presence: true, uniqueness: true  
end
