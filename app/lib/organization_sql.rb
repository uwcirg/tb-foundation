module OrganizationSQL

    COHORT_SUMMARY = <<-SQL
    SELECT * FROM users
    WHERE users.id IN (SELECT DISTINCT daily_reports.user_id 
        from daily_reports
        JOIN symptom_reports on symptom_reports.daily_report_id = daily_report.id
        WHERE daily_report.date > now() - '1 week' 
 )
    SQL
end