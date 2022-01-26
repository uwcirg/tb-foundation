class PhotoCode < ApplicationRecord
  belongs_to :photo_code_group

  validates :sub_group_code, presence: true, uniqueness: { scope: :photo_code_group_id }
  validates :title, presence: true
  validates :description, presence: true

  def full_code
    "#{self.photo_code_group.group_code}.#{self.sub_group_code}"
  end

  def group
    self.photo_code_group.group
  end
  
end
