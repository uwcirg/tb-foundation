class StripReport < ApplicationRecord
  belongs_to :participant
  belongs_to :resolution, optional: true
  
  def as_json(*args)
    {
      participant_id: participant_id,
      timestamp: timestamp,
      url_photo: url_photo,
      created_at: created_at,
      updated_at: updated_at,
      status: status,
      resolution_uuid: resolution_uuid
    }
  end


end
