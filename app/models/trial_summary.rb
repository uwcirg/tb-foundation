class TrialSummary < ActiveModelSerializers::Model
  include OrganizationSQL

  def self.generate_heatmap_data
    orgHash = {}
    Patient.non_test.where.not(status: "Pending").joins(:patient_information).order("patient_informations.datetime_patient_activated").each do |patient|
      date_hash = {}
      days = []
      patient.daily_reports.joins(:medication_report).pluck("medication_reports.medication_was_taken", :date).map { |p| date_hash["#{p[1]}"] = p[0] }
      activation_date = patient.patient_information.datetime_patient_activated
      i = 0
      days_in_treatment = patient.patient_information.days_since_app_start

      ((activation_date.to_date)..(activation_date.to_date + 180.days)).each do |day|
        i += 1
        if (i > days_in_treatment)
          days.push("futureDate")
        else
          days.push(date_hash["#{day}"] == true ? "taken" : "notTaken")
        end
      end

      if (orgHash["#{patient.organization_id}"].nil?)
        orgHash["#{patient.organization_id}"] = {}
      end

      orgHash["#{patient.organization_id}"]["#{patient.id}"] = days
    end
    return orgHash
  end

  def initialize
    @priorities = exec_query(PATIENT_RANK).as_json
  end

  def patients
    #@TODO: use Patient.group(:status) instead of individual counts?
    {
      total: Patient.non_test.count,
      active: Patient.non_test.active.count,
      pending: Patient.non_test.pending.count,
      archived: Patient.non_test.archived.count,
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

  def active_notification_enrollment
    Patient.active.group(:push_client_permission).count
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

  def self.participant_adherence_summary
    Rails.cache.fetch("monthly_adherence_summary", expires_in: 1.days) do
      Patient.non_test.where("treatment_start < ?", Date.current - 4.months).includes(:daily_reports, :medication_reports, :patient_information).map do |patient|
        {
          id: patient.id,
          age: patient.age,
          gender: patient.gender,
          two_month_adherence: patient.adherence_to_month(2),
          four_month_adherence: patient.adherence_to_month(4),
        }
      end
    end
  end

  private

  def exec_query(query)
    sql = ActiveRecord::Base.sanitize_sql [query, { organization_ids: Organization.where("id > 0").pluck(:id) }]
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
