class Analysis
  def self.deduplicated_photos
    dedup_ids = StripReport.where(participant: Participant.non_test).select("date_trunc('day',strip_reports.timestamp), participant_id, id").group("date_trunc('day',strip_reports.timestamp)", :participant_id).maximum(:id)
  end

  def self.mean_and_sd
    a = StripReport.deduped_for_stats.group(:participant_id).count.values
    mean = a.sum(0.0) / a.size
    sum = a.sum(0.0) { |element| (element - mean) ** 2 }
    variance = sum / (a.size - 1)
    standard_deviation = Math.sqrt(variance)
    puts("Mean #{mean}")
    puts("Standard Deviation #{standard_deviation}")
  end

  def self.full_mean_and_sd
    a = StripReport.non_test.group(:participant_id).count.values
    mean = a.sum(0.0) / a.size
    sum = a.sum(0.0) { |element| (element - mean) ** 2 }
    variance = sum / (a.size - 1)
    standard_deviation = Math.sqrt(variance)
    puts("Mean #{mean}")
    puts("Standard Deviation #{standard_deviation}")
  end
end
