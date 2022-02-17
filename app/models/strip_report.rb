class StripReport < ApplicationRecord
  belongs_to :participant
  belongs_to :resolution, optional: true

  scope :non_test, -> {where(participant: Participant.non_test)}
  scope :deduped_for_stats, -> {where(id: StripReport.where(participant: Participant.non_test).select("date_trunc('day',strip_reports.timestamp), participant_id, id").group("date_trunc('day',strip_reports.timestamp)",:participant_id).maximum(:id).values)}
  
  def as_json(*args)
    {
      id: id,
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
