class PatientShortSerializer < ActiveModel::Serializer
  attributes :id, :given_name, :family_name, :last_resolution, :adherence

  has_many :daily_reports, key: :reporting_summary do
    last_resolution = object.resolutions.last.resolved_at
    object.daily_reports.where("date > ?", last_resolution).order("date DESC")
  end

  def last_resolution
    object.resolutions.last.resolved_at.to_date
  end
end
