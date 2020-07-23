class Organization < ApplicationRecord
  has_many :practitioners
  has_many :patients

  include OrganizationSQL

  def cohort_summary
    hash = {}
    hash["hadSymptom"] = self.patients.had_symptom_last_week.count
    hash["activePatients"] = self.patients.group(:status).count.as_json["Active"]
    hash["pendingPatients"] = self.patients.group(:status).count.as_json["Pending"]
    return hash
  end

  def self.cohort_summary_dev(id)
    sql = sanitize_sql [TESTER, { organization_id: id }]
    #sql = TESTER
    # result_value = connection.select_value(sql)
    return ActiveRecord::Base.connection.exec_query(sql).to_a
  end


  def self.test_dev(id)
    #sql = sanitize_sql [COHORT_SUMMARY, { organization_id: id }]
    sql = sanitize_sql [PATIENTS_IN_COHORT, { organization_id: id }]
    # result_value = connection.select_value(sql)
    return ActiveRecord::Base.connection.exec_query(sql).to_a
  end


end
