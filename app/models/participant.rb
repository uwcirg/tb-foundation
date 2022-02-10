class Participant < ApplicationRecord
  has_many :medication_reports, dependent: :destroy
  has_many :strip_reports, dependent: :destroy
  has_many :symptom_reports, dependent: :destroy
  has_many :notes, as: :author, dependent: :destroy

  validates :name, presence: true
  validates :phone_number, presence: true, uniqueness: true
  validates :treatment_start, presence: true
  validates :password_digest, presence: true

  scope :non_test, -> { where(uuid: redcap_map.keys) }

  def self.redcap_map
    {
      "9c6639d0-215a-4017-bbec-48be749c3301": 102,
      "ffa14305-8c0d-4646-b290-a4726e8d436f": 103,
      "d113eb86-4a12-4690-9bdc-913012302e2b": 105,
      "52daf48a-4727-4e36-9937-fe8f06b65e63": 124,
      "f9ce51fa-3f24-4670-a83d-61bdb9ee1fe9": 125,
      "4a96769d-f11c-47f0-b787-3bcab81c23b9": 107,
      "a9b4217e-858d-4216-bfcb-b33bc118d2b4": 109,
      "86d0ad85-fca1-4985-984a-27d60f705c53": 111,
      "e2e6b123-b293-41e4-9a90-4ce7f57e57bc": 113,
      "43500505-5b89-40ff-8ca4-8e854832c565": 115,
      "4e0703ee-fb16-4937-937e-ff47ed70fd04": 118,
      "789434b2-7f3d-453b-9f65-67823a73030b": 119,
      "55f0e383-e5fb-4ba0-8dcc-7a53c78884ef": 120,
      "978d07a8-2fcb-4e30-ba87-b7caebe9e74b": 126,
      "ecdac63c-1a90-4810-a0b4-ff24611bc104": 130,
      "245e79a0-7f87-45ba-a022-a7ac62973ea1": 131,
      "49050a92-bd26-498e-893f-97b8ab393077": 134,
      "a7dfbe1a-1916-4940-b6c1-5b0b558b196a": 135,
      "e0f625ea-ff86-4ed0-89ec-07e9dbe71a05": 137,
      "368c36c5-daac-481a-ac74-430cae3162ef": 141,
      "b7156f36-2aea-4d0e-8557-5763cfc0074c": 109,
      "df31380f-36ca-45b1-91c1-02e82dff196a": 137,
      "842e7de3-24ca-467d-97f7-2cad70a8a214": 137,
    }
  end

  def as_json(*args)
    {
      uuid: uuid,
      name: name,
      phone_number: phone_number,
      treatment_start: treatment_start,

      medication_reports: medication_reports,
      strip_reports: strip_reports,
      symptom_reports: symptom_reports,
      notes: notes,
      adherence: adherence,
    }
  end

  def summary
    {
      uuid: uuid,
      name: name,
      phone_number: phone_number,
      treatment_start: treatment_start,

      medication_reports: medication_reports.where(resolution_uuid: nil),
      strip_reports: strip_reports.where(resolution_uuid: nil),
      symptom_reports: symptom_reports.where(resolution_uuid: nil),

      notes: notes,
      adherence: adherence,
    }
  end

  def adherence
    days = (Time.current.to_date - treatment_start).to_i

    if days == 0
      days = 1
    end

    report_dates = medication_reports.map do |report|
      report.timestamp.to_date
    end.uniq.count

    report_dates.to_f / days.to_f
  end
end
