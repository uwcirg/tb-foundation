class ContactTracingSurveySerializer < ActiveModel::Serializer
  attributes :id, :number_of_contacts, :number_of_contacts_tested
  #has_one :patient
end
