class TrialSummarySerializer < ActiveModel::Serializer

    attributes :patients, :photos, :adherence_summary, :site_summaries


end