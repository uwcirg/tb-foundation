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

  def patient_priorities
    sql = ActiveRecord::Base.sanitize_sql [PATIENT_RANK, { organization_id: self.id }]
    hash = {}
    q = ActiveRecord::Base.connection.exec_query(sql).to_a.each do |line|
        hash[line["patient_id"]] = line["priority"]
    end
    puts(hash)
    return(hash)
  end


  def test_dev
    sql = ActiveRecord::Base.sanitize_sql [SUMMARY_OF_PRIORITIES, { organization_id: self.id }]
    puts(ActiveRecord::Base.connection.exec_query(sql).to_a)
  end


end
