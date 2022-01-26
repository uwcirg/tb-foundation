class PhotoCode < ApplicationRecord

    belongs_to :photo_code_group

    validates :sub_group_code, presence: true, uniqueness: {scope: :photo_code_group_id}
    validates :title, presence: true
    validates :description, presence: true

end