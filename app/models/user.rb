class User < ApplicationRecord
  belongs_to :organization
  has_many :messages, dependent: :destroy
  has_many :channels, dependent: :destroy
  has_many :messaging_notifications, dependent: :destroy
  has_many :push_notification_statuses, dependent: :destroy

  enum locale: { "en": 0, "es-AR": 1, "id": 2 }
  enum type: { Patient: 0, Practitioner: 1, Administrator: 2, Expert: 3, BioEngineer: 4, Coordinator: 5 }
  enum status: { Pending: 0, Active: 1, Archived: 2 }
  enum gender: { Man: 0, Woman: 1, Other: 2, TransMan: 3, TransWoman: 4, Nonbinary: 5 }

  validates :password_digest, presence: true
  validates :email, uniqueness: true, allow_nil: true
  validates :phone_number, uniqueness: true, allow_nil: true

  after_commit :create_unread_messages_async, on: :create

  attribute :time_zone, :string, default: ApplicationTime.time_zone

  def full_name
    "#{self.given_name} #{self.family_name}"
  end

  def unsubscribe_push
    self.update(push_p256dh: nil, push_auth: nil, push_url: nil)
  end

  def send_push_to_user(title, body, app_url = "/", type = 0,actions=nil)
    PushNotificationSender.new(self, title, body, app_url, type,actions).send_notification
  end

  def update_last_message_seen(channel_id, number)
    messaging_notification = MessagingNotification.find_by(channel_id: channel_id, user_id: self.id)

    if (messaging_notification.nil?)
      MessagingNotification.create!(channel_id: channel_id, user_id: self.id, read_message_count: number)
    else
      messaging_notification.update(read_message_count: number)
    end
  end

  def create_unread_messages
    self.available_channels.map do |c|
      new_unread = self.messaging_notifications.create(channel_id: c.id, user_id: self.id, read_message_count: c.messages.count)
      if (new_unread.valid?)
        new_unread.save
      end
    end
  end

  #Used in seeding the database with test data - so that a bunch of notificaitons are not set
  def send_message_no_push(body, channel_id)
    one = self.messages.new(body: body, channel_id: channel_id)
    one.skip_notify = true
    one.save
  end

  def update_password(new_password_string, is_password_reset = false)
    self.update(password_digest: BCrypt::Password.create(new_password_string), has_temp_password: is_password_reset)
  end

  def check_current_password(password)
    BCrypt::Password.new(self.password_digest) == password
  end

  def available_channels
    Pundit.policy_scope!(self, Channel)
  end

  def admin?
    self.type == "Administrator"
  end

  def practitioner?
    self.type == "Practitioner"
  end

  def patient?
    self.type == "Patient"
  end

  def bio_engineer?
    self.type == "BioEngineer"
  end

  def coordinator?
    self.type == "Coordinator"
  end

  def localized_datetime
    Time.current.in_time_zone(self.time_zone)
  end

  def localized_date
    localized_datetime.to_date
  end

  def session_length
    patient? ? (Time.now + 6.months + 2.weeks) : (Time.now + 1.week);
  end

  private

  def create_unread_messages_async
    ::UnreadMessageCreationWorker.perform_async(self.id)
  end
end
