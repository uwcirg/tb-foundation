class PatientShortSerializer < ActiveModel::Serializer
  attributes :id, :given_name, :family_name, :last_resolution, :adherence

  has_many :daily_reports, key: :reporting_summary do
    last_resolution = object.resolutions.last.resolved_at

    #TODO - adapt to use users current date as input
    object.daily_reports.where("created_at > ? OR date >= ?", last_resolution, Date.today - 1.day).order("date DESC")
  end

  def last_resolution
    object.resolutions.last.resolved_at.to_date
  end
end
