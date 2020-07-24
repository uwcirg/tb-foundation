module OrganizationSQL
  COHORT_SUMMARY = <<-SQL
    SELECT * FROM users
    WHERE users.id IN (SELECT DISTINCT daily_reports.user_id 
        from daily_reports
        JOIN symptom_reports on symptom_reports.daily_report_id = daily_report.id
        WHERE daily_report.date > now() - '1 week' 
 )
    SQL

  PATIENTS_IN_COHORT = <<-SQL
SELECT id from users
WHERE type = 0 AND organization_id = :organization_id AND users.status = 1
SQL

  NUMBER_DAYS_SYMPTOMS = <<-SQL
SELECT patients.id as user_id, CASE 
WHEN symptoms_table.days_with_symptoms IS NULL then 0
ELSE symptoms_table.days_with_symptoms
 END as days_with_symptoms
FROM (#{PATIENTS_IN_COHORT}) as patients
LEFT JOIN 
(SELECT daily_reports.user_id as user_id, count(filtered_symptoms.id) as days_with_symptoms
FROM (SELECT *  FROM symptom_reports
WHERE symptom_reports.user_id IN (#{PATIENTS_IN_COHORT})
AND (redness=true OR hives=TRUE OR fever=TRUE OR appetite_loss=TRUE OR blurred_vision=TRUE OR sore_belly=TRUE OR yellow_coloration=TRUE OR difficulty_breathing=TRUE OR facial_swelling=TRUE OR nausea=TRUE)
) as filtered_symptoms
JOIN daily_reports on filtered_symptoms.daily_report_id = daily_reports.id
WHERE daily_reports.date > CURRENT_TIMESTAMP - interval '1 week'
GROUP BY daily_reports.user_id) as symptoms_table on symptoms_table.user_id = patients.id
SQL

  ADHERENCE = <<-SQL
SELECT user_starts.id as user_id,  round( number_reports/days_since_start::decimal, 3 ) as adherence FROM 
  (SELECT daily_reports.user_id as patient_id,count(daily_reports.id) as number_reports 
  FROM daily_reports 
  JOIN medication_reports ON daily_reports.id = medication_reports.daily_report_id
  WHERE daily_reports.user_id IN (#{PATIENTS_IN_COHORT}) AND medication_reports.medication_was_taken = true
  GROUP BY daily_reports.user_id) AS report_counts 
JOIN ( SELECT DATE_PART('day',(NOW() - INTERVAL '1 DAY')::date - (treatment_start - INTERVAL '1 DAY'))::integer as days_since_start, id FROM users) as user_starts
ON report_counts.patient_id = user_starts.id
SQL

  #Modified this function so that it returns all patients, even ones who have not submitted a  report yet, this will allow a 3rd priortiy of new patients (3)
  PATIENT_RANK = <<-SQL
  SELECT all_patients.id as patient_id, 
  CASE 
  WHEN ranks.priority IS NULL then 3
ELSE ranks.priority
  END as priority
  FROM 
    (#{PATIENTS_IN_COHORT}) as all_patients
    LEFT JOIN(
SELECT combined.patient_id as patient_id, CASE
when (combined.adherence between 0 and 0.8) OR ((combined.adherence between 0.8 and 0.9) AND combined.days_with_symptoms >= 1 )   then 2
when (combined.adherence between 0.8 and 0.9) OR combined.days_with_symptoms >= 1 then 1
when (combined.adherence between 0.9 and 1) AND combined.days_with_symptoms = 0  then 0
else 0
end as priority
FROM (
SELECT weekly_symptoms.user_id as patient_id, * FROM (#{ADHERENCE}) as adherence
JOIN (#{NUMBER_DAYS_SYMPTOMS}) as weekly_symptoms on weekly_symptoms.user_id = adherence.user_id) as combined) as ranks on all_patients.id = ranks.patient_id
SQL

  SUMMARY_OF_PRIORITIES = <<-SQL
  SELECT ranks.priority, count(ranks.patient_id) FROM (#{PATIENT_RANK}) as ranks
  GROUP BY ranks.priority

SQL

  PATIENT_STATUS = <<-SQL
    SELECT status,count(id) from users
    WHERE type = 0 AND organization_id = :organization_id
    GROUP BY status
SQL

SYMPTOM_SUMMARY = <<-SQL

SELECT sum(redness::int) as redness,
sum(hives::int) as hives,
sum(fever::int) as fever,
sum(appetite_loss::int) as appetite_loss,
sum(blurred_vision::int) as blurred_vision,
sum(sore_belly::int) as sore_belly,
sum(yellow_coloration::int) as yellow_coloration,
sum(difficulty_breathing::int) as difficulty_breathing,
sum(facial_swelling::int) as facial_swelling,
sum(nausea::int) as nausea FROM 
( SELECT * FROM symptom_reports
    JOIN users on symptom_reports.user_id = users.id
    WHERE users.organization_id = :organization_id) as org_symptoms
INNER JOIN daily_reports ON org_symptoms.daily_report_id = daily_reports.id 
WHERE daily_reports.date > CURRENT_TIMESTAMP - interval '1 week'

SQL
end
