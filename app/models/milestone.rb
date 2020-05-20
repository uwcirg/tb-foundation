class Milestone < ApplicationRecord
    belongs_to :patient, :foreign_key=> :user_id
    validates :title, presence: true

  end
  