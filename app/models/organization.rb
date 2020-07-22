class Organization < ApplicationRecord
  has_many :practitioners
  has_many :patients

  include OrganizationSQL

  def cohort_summary
    hash = {}
    hash["hadSymptom"] = self.patients.had_symptom_last_week.count
    hash = hash.merge(self.patients.group(:status).count.as_json)
    return hash
  end

  def self.cohort_summary_dev(id)
    #sql = sanitize_sql [COHORT_SUMMARY, { organization_id: id }]
    sql = COHORT_SUMMARY
    # result_value = connection.select_value(sql)
    return ActiveRecord::Base.connection.exec_query(sql)
  end


end
