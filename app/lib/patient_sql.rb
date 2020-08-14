module PatientSQL

  #TODO adapt this to match the users timezone
  MISSED_DAYS = <<-SQL
SELECT to_char(series_date::date at time zone 'ART', 'YYYY-MM-DD')  AS date FROM (
SELECT series_date, combined.id AS report_id
FROM generate_series(
      ( SELECT resolved_at::date
        FROM resolutions
        WHERE patient_id = :user_id
        AND kind = 1
        ORDER BY resolved_at DESC
        LIMIT 1
      ),
      ((current_date at time zone 'ART')::date ),
      '1 day'
    ) AS series_date
     LEFT JOIN (SELECT * FROM daily_reports WHERE user_id = :user_id ) as combined ON combined.date::date = series_date) AS sq
WHERE sq.report_id IS NULL
ORDER BY date DESC
SQL

  #TODO adapt this to match the users timezone
  USER_STREAK_DAYS_SQL = <<-SQL
    SELECT (((current_date at time zone 'ART')::date )- series_date::date) AS days
    FROM generate_series(
          ( SELECT date::date FROM daily_reports
            WHERE daily_reports.user_id = :user_id
            ORDER BY date ASC
            LIMIT 1
          ) - 1,
          ((current_date at time zone 'ART')::date ),
          '1 day'
        ) AS series_date
    LEFT OUTER JOIN (
      SELECT daily_reports.* FROM daily_reports
      LEFT JOIN medication_reports on daily_reports.id =  medication_reports.daily_report_id
      WHERE medication_reports.medication_was_taken = true
      
    ) as combined ON combined.user_id = :user_id AND
                             combined.date::date = series_date
    GROUP BY series_date
    HAVING COUNT(combined.id) = 0
    ORDER BY series_date DESC
    LIMIT 1
  SQL
end

PRIORITY = <<-SQL
SELECT
SUM (case when tab.adherence between 0 and 0.8 then 1 else 0 end) high,
SUM (case when tab.adherence between 0.8 and 0.9 then 1 else 0 end) mid,
SUM (case when tab.adherence between 0.9 and 1 then 1 else 0 end) low
FROM (
  SELECT number_reports, days_since_start, user_starts.given_name,user_starts.family_name,  round( number_reports/days_since_start::decimal, 3 ) as adherence FROM 
  (SELECT daily_reports.user_id as patient_id,count(daily_reports.id) as number_reports 
  FROM daily_reports 
  JOIN medication_reports ON daily_reports.id = medication_reports.daily_report_id
  JOIN symptom_reports ON daily_reports.id = symptom_reports.daily_report_id
  WHERE medication_reports.medication_was_taken = true
  GROUP BY daily_reports.user_id) AS report_counts 
JOIN ( SELECT DATE_PART('day',(NOW() - INTERVAL '1 DAY')::date - (treatment_start - INTERVAL '1 DAY'))::integer as days_since_start, id, given_name, family_name FROM users) as user_starts
ON report_counts.patient_id = user_starts.id) as tab
SQL

#(redness=true OR hives=TRUE OR fever=TRUE OR appetite_loss=TRUE OR blurred_vision=TRUE OR sore_belly=TRUE OR yellow_coloration=TRUE OR difficulty_breathing=TRUE OR facial_swelling=TRUE OR nausea=TRUE)
SYMPTOM_SUMMARY = <<-SQL
SELECT 
count(symptoms.redness=true) as redness,
count(symptoms.hives=true) as hives,
count(symptoms.fever=true) as fever,
count(symptoms.appetite_loss=true) as appetite_loss,
count(symptoms.blurred_vision=true) as blurred_vision,
count(symptoms.sore_belly=true) as sore_belly,
count(symptoms.yellow_coloration=true) as yellow_coloration,
count(symptoms.facial_swelling=true) as facial_swelling,
count(symptoms.nausea=true) as nausea
FROM
(SELECT * FROM symptom_reports
INNER JOIN daily_reports ON symptom_reports.daily_report_id = daily_reports.id
WHERE symptom_reports.user_id = :user_id AND daily_reports.date >  NOW() - INTERVAL ':num_days DAY'  ) as symptoms
SQL

SINGLE_PATIENT_ADHERENCE= <<-SQL
SELECT round( number_reports/days_since_start::decimal, 3 ) as adherence FROM 
  (SELECT daily_reports.user_id as patient_id,count(daily_reports.id) as number_reports 
  FROM daily_reports 
  JOIN medication_reports ON daily_reports.id = medication_reports.daily_report_id
  WHERE daily_reports.user_id = :user_id AND medication_reports.medication_was_taken = true
  GROUP BY daily_reports.user_id) AS report_counts 
JOIN ( SELECT (DATE_PART('day',(NOW() - INTERVAL '1 DAY')::date - (treatment_start - INTERVAL '1 DAY'))::integer) as days_since_start, id FROM users) as user_starts
ON report_counts.patient_id = user_starts.id
SQL

