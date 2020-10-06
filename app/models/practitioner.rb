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
    #If you need more information from the DailyReport change this query to use DailyReport as the base, then join the other tables
    photos_needing_approval = PhotoReport.where(approved: nil).joins(:daily_report).joins(:patient).where(patient: self.patients ).order("daily_reports.created_at desc")
    return(photos_needing_approval)
  end

  def get_historical_photos
    historical_photos = PhotoReport.where.not(approved: nil).joins(:daily_report).joins(:patient).where(patient: self.patients )
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
    latest_resolutions = Resolution.where(kind: "MissedMedication", patient: self.patients).select("MAX(resolved_at) as last_resolution, patient_id").group(:patient_id)
    new_list = []

    reports_per_patient = DailyReport.since_last_missing_resolution.where(patient: self.patients).group(:user_id).count()

    latest_resolutions.each do |resolution|
      days_since = (DateTime.now.to_date - resolution.last_resolution.to_date).to_i
      if (!reports_per_patient[resolution.patient_id].nil? && days_since > reports_per_patient[resolution.patient_id]  )
        new_list.push({"patientId": resolution.patient_id})
      end
    end

    return(new_list)
  end

  def patients_where_photo_day
    to_send = []
    select = self.patients.active
    select.each do |patient|
      list = JSON.parse(patient.medication_schedule)
    end
  end

  def tasks_completed_today
    self.resolutions.where('resolved_at BETWEEN ? AND ?', DateTime.now.beginning_of_day, DateTime.now.end_of_day).count + PhotoReport.where('approval_timestamp BETWEEN ? AND ? AND practitioner_id = ?',DateTime.now.beginning_of_day, DateTime.now.end_of_day,self.id).count
  end

  def summary_of_daily_medication_reporting
    DailyReport.today.joins(:medication_report).where(user_id: self.patients.active.pluck(:id)).group("medication_reports.medication_was_taken").count
  end

  def available_channels
    return Channel.joins(:user)
    .where(is_private: true, users: { organization_id: self.organization_id, type: "Patient"})
    .or(Channel.joins(:user).where(user_id: self.id))
    .or(Channel.joins(:user).where(is_private: false)).order(:created_at)
  end

end