class TrialSummarySerializer < ActiveModel::Serializer

    attributes :patients, :photos, :adherence_summary, :site_summaries, :request_stats

end