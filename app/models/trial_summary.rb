class TrialSummary < ActiveModelSerializers::Model
  include OrganizationSQL

  def initialize
    @priorities = exec_query(PATIENT_RANK).as_json
  end

  def patients
    {
      active: Patient.non_test.active.count,
      pending: Patient.non_test.pending.count,
      priorities: priority_summary,
    }
  end

  def photos
    return({
            number_requested: PhotoDay.requested.where(patient: Patient.non_test.active).count,
            number_of_submissions: PhotoReport.all.count,
            number_conclusive: PhotoReport.where(approved: true).count,
            today: {
              number_requested: PhotoDay.requested.where(patient: Patient.non_test.active, date: Date.today).count,
              number_of_submissions: PhotoReport.where(date: Date.today).count,
            },
          })
  end

  def adherence_summary
    return @priorities
  end

  def site_summaries
    groups = @priorities.select { |d| !d["organization_id"].nil? }
  end

  def request_stats
    ((Date.today - 1.month)..Date.today).map { |date| { date: date.iso8601, submitted: PhotoReport.where(patient: Patient.active.non_test, daily_report_id: DailyReport.where(date: date)).count, requested: PhotoDay.where(patient: Patient.active.non_test, date: date).count } }
  end

  def daily_reports
    ((Date.today - 1.month)..Date.today).map { |date| { date: date.iso8601, submitted: DailyReport.where(date: date, patient: Patient.active.non_test).count, requested: Patient.active.non_test.where("app_start <= ? OR app_start IS NULL", date).count } }
  end

  def patient_registration
    Patient.non_test.active.group("DATE_TRUNC('week',treatment_start)").count
  end

  private

  def exec_query(query)
    sql = ActiveRecord::Base.sanitize_sql [query, { organization_ids: Organization.all.pluck(:id) }]
    return ActiveRecord::Base.connection.exec_query(sql).to_a
  end

  def priority_summary
    hash = {}
    exec_query(SUMMARY_OF_PRIORITIES).each do |line|
      case line["priority"]
      when 0
        hash["low"] = line["count"]
      when 1
        hash["medium"] = line["count"]
      when 2
        hash["high"] = line["count"]
      when 3
        hash["new"] = line["count"]
      else
        puts("Unexpected SQL Return for priority summary")
      end
    end
    return hash
  end
end
