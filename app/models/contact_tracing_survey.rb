class ContactTracingSurvey < ApplicationRecord
  belongs_to :patient

  def self.policy_class
    PatientRecordPolicy
  end
  
end
