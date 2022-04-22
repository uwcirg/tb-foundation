class PatientIssueSerializer < ActiveModel::Serializer
  attributes :full_name,
             :adherence,
             :last_contacted,
             :priority,
             :channel_id,
             :last_general_resolution,
             :id,
             :weeks_in_treatment

  def channel_id
    object.channels.where(is_private: true).first.id
  end
  
end
