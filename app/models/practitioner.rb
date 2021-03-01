class Practitioner < User
  belongs_to :organization
  has_many :patients, through: :organization
  has_many :resolutions
  has_many :patient_notes
  validates :type, inclusion: { in: ["Practitioner"] }
  validates :email, presence: true

  after_create :create_private_message_channel

  def create_unread_messages
    super
    Channel.where(is_private: true, user: self.patients).map do |c|
      self.messaging_notifications.create!(channel_id: c.id, user_id: self.id, read_message_count: 0)
    end
  end

  def create_private_message_channel
    self.channels.create!(title: "tb-expert-chat", is_private: true)
  end

  def get_photos
    photos_needing_approval = PhotoReport.where("approved IS NULL AND photo_url IS NOT NULL")
    .joins(:daily_report).joins(:patient)
    .where(patient: self.patients.active)
    .order("daily_reports.created_at desc")
    return(photos_needing_approval)
  end

  def get_historical_photos
    historical_photos = PhotoReport.where.not(approved: nil).joins(:daily_report).joins(:patient).where(patient: self.patients)
    return(process_photos(historical_photos))
  end

  def process_photos(photos)
    list = []
    photos.each do |report|
      list.push({ "url": report.get_url, "photo_id": report.id, "approved": report.approved })
    end

    return list
  end

  def patient_names
    hash = {}
    Patient.where(practitioner_id: self.id).each do |patient|
      hash[patient.id] = "#{patient.given_name} #{patient.family_name}"
    end
    return hash
  end

  def patients_missed_medication
    
    new_list = []
    latest_resolutions = Resolution.where(kind: "MissedMedication", patient: self.patients.active).select("MAX(resolved_at) as last_resolution, patient_id").group(:patient_id)
    reports_per_patient = DailyReport.since_last_missing_resolution.where(patient: self.patients).group(:user_id).count()

    latest_resolutions.each do |resolution|
      days_since = (DateTime.now.to_date - resolution.last_resolution.to_date).to_i

      #If there are no reports found for that patient, then default to zero instead of skipping them
      total_reports = reports_per_patient[resolution.patient_id] || 0
      if (days_since > total_reports)
        new_list.push({ "patientId": resolution.patient_id })
      end
    end

    return(new_list)
  end

  def patients_missed_photo
    missed_days = PhotoDay.since_last_missing_photo_resolution.where("photo_days.date > ?", Date.today - 1.week)
      .where(patient: self.patients.active)
      .joins("LEFT JOIN daily_reports on daily_reports.date = photo_days.date AND daily_reports.user_id = photo_days.patient_id",
             "LEFT JOIN photo_reports on photo_reports.daily_report_id = daily_reports.id")
      .where("photo_reports.id IS NULL OR photo_reports.photo_was_skipped = true ")
      .order("photo_days.date DESC, daily_reports.user_id")
      .pluck("photo_days.patient_id", "photo_reports.why_photo_was_skipped", "photo_days.date")

    hash = {}

    missed_days.each do |patient_day|
      old_entry = hash["#{patient_day[0]}"] || []
      day_to_add = { date: patient_day[2], reason: patient_day[1] || "" }
      hash["#{patient_day[0]}"] = old_entry.append(day_to_add)
    end

    return hash
  end

  def tasks_completed_today
    self.resolutions.where("resolved_at BETWEEN ? AND ?", DateTime.now.beginning_of_day, DateTime.now.end_of_day).count + PhotoReport.where("approval_timestamp BETWEEN ? AND ? AND practitioner_id = ?", DateTime.now.beginning_of_day, DateTime.now.end_of_day, self.id).count
  end

  def summary_of_daily_medication_reporting
    DailyReport.today.joins(:medication_report).where(user_id: self.patients.active.pluck(:id)).group("medication_reports.medication_was_taken").count
  end

  def available_channels
    return Channel.joins(:user)
             .where(is_private: true, users: { organization_id: self.organization_id, type: "Patient" })
             .or(Channel.joins(:user).where(user_id: self.id))
             .or(Channel.joins(:user).where(is_private: false)).order(:created_at)
  end

  private

  def latest_resolution_by_kind(kind)
    Resolution.where(kind: kind, patient: self.patients.active).select("MAX(resolved_at) as last_resolution, patient_id").group(:patient_id)
  end
end
