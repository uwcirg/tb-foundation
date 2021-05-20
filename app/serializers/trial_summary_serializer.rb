class TrialSummarySerializer < ActiveModel::Serializer

    attributes :patients, :photos, :adherence_summary, :site_summaries, :photo_request_stats, :reporting_stats, :registration_by_month, :symptom_summary

end