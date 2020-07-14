module PatientSQL

#TODO adapt this to match the users timezone
MISSED_DAYS = <<-SQL
SELECT to_char(series_date::date at time zone 'ART', 'YYYY-MM-DD')  AS date FROM (
SELECT series_date, combined.id AS report_id
FROM generate_series(
      ( SELECT resolved_at::date
        FROM resolutions
        WHERE patient_id = :user_id
        AND kind = 2
        ORDER BY resolved_at DESC
        LIMIT 1
      ),
      ((current_date at time zone 'ART')::date ),
      '1 day'
    ) AS series_date
     LEFT JOIN (SELECT * FROM daily_reports WHERE user_id = :user_id ) as combined ON combined.date::date = series_date) AS sq
WHERE sq.report_id IS NULL
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