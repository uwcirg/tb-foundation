require "csv"

class SymptomQueries
  GOOD_SYMPTOM_REPORTS = <<-SQL
    SELECT * FROM symptom_reports JOIN participants 
    ON participants.uuid = symptom_reports.participant_id
    WHERE participants.name != 'TEST'
    SQL

  DEDUPLICATED_TESTS_REMOVED = <<-SQL
    SELECT DISTINCT ON (reports.created_date, reports.participant_id) *
    FROM (SELECT date_trunc('day',timestamp) as created_date, symptom_reports.* FROM symptom_reports
    JOIN participants on participants.uuid = symptom_reports.participant_id
    WHERE participants.name != 'TEST'
    ) as reports
    order by reports.created_date, reports.participant_id, reports.created_at desc
  SQL

  DEDUP_IDS = <<-SQL
    SELECT T.id FROM (#{DEDUPLICATED_TESTS_REMOVED}) as T
    SQL

  SIMPLE_COUNT = <<-SQL
  SELECT 
  s.participant_id,
  count(CASE 
    WHEN s.nausea THEN 1 
    WHEN s.redness THEN 1 
    WHEN s.hives THEN 1
    WHEN s.fever THEN 1
    WHEN s.appetite_loss THEN 1 
    WHEN s.blurred_vision THEN 1
    WHEN s.sore_belly THEN 1
    WHEN s.yellow_coloration THEN 1
    WHEN s.difficulty_breathing THEN 1 
    WHEN s.facial_swelling THEN 1
    WHEN s.headache THEN 1
    WHEN s.dizziness THEN 1
    WHEN s.other != '' THEN 1
    END) as non_zero_count
    FROM (#{DEDUPLICATED_TESTS_REMOVED}) as s
    GROUP BY s.participant_id
  SQL

  SYMPTOM_COUNT = <<-SQL
      SELECT 
      s.participant_id,
      count(CASE WHEN s.nausea THEN 1 END) as nausea_count,
      count(CASE WHEN s.redness THEN 1 END) as redness_count,
      count(CASE WHEN s.hives THEN 1 END) as hives_count,
      count(CASE WHEN s.fever THEN 1 END) as fever_count,
      count(CASE WHEN s.appetite_loss THEN 1 END) as appetite_loss_count,
      count(CASE WHEN s.blurred_vision THEN 1 END) as fblurred_vision_count,
      count(CASE WHEN s.sore_belly THEN 1 END) as sore_belly_count,
      count(CASE WHEN s.yellow_coloration THEN 1 END) as yellow_coloration_count,
      count(CASE WHEN s.difficulty_breathing THEN 1 END) as difficulty_breathing_count,
      count(CASE WHEN s.facial_swelling THEN 1 END) as facial_swelling_count,
      count(CASE WHEN s.headache THEN 1 END) as headache_count,
      count(CASE WHEN s.dizziness THEN 1 END) as dizziness_count,
      count(CASE WHEN s.other != '' THEN 1 END) as other_count
      FROM (#{DEDUPLICATED_TESTS_REMOVED}) as s
    GROUP BY s.participant_id
    SQL

  TEST = <<-SQL
   SELECT date_trunc('day',created_at) as created_date, * FROM symptom_reports
  SQL

  WEEKLY_SUMMAY = <<-SQL
SELECT *
SQL

  #    GROUP BY date_trunc('day', symptom_reports.created_at), symptom_reports.participant_id
  def self.symptom_summary
    sql = ActiveRecord::Base.sanitize_sql [SYMPTOM_COUNT]
    ActiveRecord::Base.connection.exec_query(sql).to_a
  end

  def self.sql_count
    sql = ActiveRecord::Base.sanitize_sql [SIMPLE_COUNT]
    ActiveRecord::Base.connection.exec_query(sql).to_a
  end

  def self.deduped_ids
    sql = ActiveRecord::Base.sanitize_sql [DEDUP_IDS]
    array = ActiveRecord::Base.connection.exec_query(sql).to_a
    # maped = array.map{|row| return row['id']}
    array.map { |row| row["id"] }
  end

  def self.export_csv
    file = "#{Rails.root}/tmp/symptom_count_data.csv"

    sql = ActiveRecord::Base.sanitize_sql [SIMPLE_COUNT]
    table = ActiveRecord::Base.connection.exec_query(sql)

    CSV.open(file, "w") do |writer|
      writer << table.first.map { |a, v| a }
      table.each do |s|
        writer << s.map { |a, v| v }
      end
    end
  end

  def self.time_map
    hash = {}
    reports = SymptomReport.includes("participant").where(id: self.deduped_ids)#.where.not(participant_id: "f9ce51fa-3f24-4670-a83d-61bdb9ee1fe9")
    reports.each do |report|
      had_symptoms = report.reported_symptoms.length > 0
      day_of_treatment = (report.timestamp.to_date - report.participant.treatment_start.to_date).to_i / 7 + 1
      if (had_symptoms)
        new_value = hash["#{day_of_treatment}"] ? hash["#{day_of_treatment}"] + 1 : 1
        hash["#{day_of_treatment}"] = new_value
      end
    end

    hash.keys.map{|key| {week: key, number_of_reports: hash["#{key}"]} }.to_json

  end
end
