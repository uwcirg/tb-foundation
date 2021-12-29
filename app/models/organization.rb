class Organization < ApplicationRecord
  include OrganizationSQL

  has_many :practitioners
  has_many :patients

  after_commit :create_organization_channel, on: :create

  def add_pending_patient(params,code)
    code_digest = BCrypt::Password.create(code)
    params = params.merge(status: "Pending", organization: self, password_digest: code_digest)
    return Patient.create(params)
  end

  def cohort_summary
    hash = {}
    status = {}
    exec_query(PATIENT_STATUS).each do |line|
      status[User.statuses.keys[line["status"]].downcase] = line["count"]
    end

    hash = hash.merge({ status: status })
    hash = hash.merge({ priority: priority_summary })
    hash = hash.merge({ symptoms: symptom_summary })
    return hash
  end

  def patient_adherence
    exec_query(ADHERENCE)
  end

  def patient_priorities
    hash = {}
    exec_query(PATIENT_RANK).each do |line|
      hash[line["patient_id"]] = {priority: line["priority"]}
    end
    return(hash)
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

  def symptom_summary
    hash = {}
    results = exec_query(FULL_SYMPTOM_SUMMARY)[0]
    results.keys.each do |value|
      hash[value] = results[value]
    end
    hash
  end

  def create_organization_channel
    Channel.create!(title: self.title, organization_id: self.id, is_private: true, category: "SiteGroup")
  end

  def practitioner_messages_per_patient
    (Message.where(user: self.practitioners).count.to_f / self.patients.count.to_f).round(2)
  end

  private

  def exec_query(query)
    sql = ActiveRecord::Base.sanitize_sql [query, { organization_ids: [self.id] }]
    return ActiveRecord::Base.connection.exec_query(sql).to_a
  end
  
end
