class TrialSummary < ActiveModelSerializers::Model
  include OrganizationSQL

  def initialize
    @priorities = exec_query(PATIENT_RANK).as_json
  end

  def patients
    {
      active: Patient.non_test.active.count,
      pending: Patient.non_test.pending.count,
      archived: Patient.non_test.archived.count,
      priorities: priority_summary
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

  def photo_request_stats
    ((Date.today - 1.month)..Date.today).map { |date| { date: date.iso8601, submitted: PhotoReport.where(patient: Patient.active.non_test, daily_report_id: DailyReport.where(date: date)).count, requested: PhotoDay.where(patient: Patient.active.non_test, date: date).count } }
  end

  def reporting_stats
    ((Date.today - 1.month)..Date.today).map { |date| { date: date.iso8601, submitted: DailyReport.where(date: date, patient: Patient.active.non_test).count, requested: Patient.active.non_test.where("app_start <= ? OR app_start IS NULL", date).count } }
  end

  def registration_by_month
    results = Patient.non_test.group("DATE_TRUNC('month',treatment_start AT TIME ZONE
      'America/Argentina/Buenos_Aires')::date").order("DATE_TRUNC('month',treatment_start AT TIME ZONE
      'America/Argentina/Buenos_Aires')::date").count
  end

  def symptom_summary
    hash = {}
    results = exec_query(FULL_SYMPTOM_SUMMARY)[0]
    results.keys.each do |value|
      hash[value] = results[value]
    end
    hash
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
