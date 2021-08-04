class ContactTracingSurveySerializer < ActiveModel::Serializer
  attributes :id,
  :patient_id,
  :created_at, 
  :number_of_contacts, 
  :number_of_contacts_tested
end
