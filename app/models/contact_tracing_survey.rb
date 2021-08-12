class ContactTracingSurvey < ApplicationRecord
  belongs_to :patient
  validates :number_of_contacts, presence: true
  validates :number_of_contacts_tested, presence: true

  def self.policy_class
    PatientRecordPolicy
  end
  
end
