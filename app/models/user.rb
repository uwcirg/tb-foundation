require "webpush"

class User < ApplicationRecord
  belongs_to :organization
  has_many :messages,dependent: :destroy
  has_many :channels,dependent: :destroy
  has_many :messaging_notifications, dependent: :destroy

  enum locale: { "en": 0, "es-AR": 1 }
  enum type: { Patient: 0, Practitioner: 1, Administrator: 2 }
  enum status: { Pending: 0, Active: 1, Archived: 2 }
  enum gender: { Male: 0, Female: 1, Other: 2 }

  validates :password_digest, presence: true
  validates :email, uniqueness: true, allow_nil: true
  validates :phone_number, uniqueness: true, allow_nil: true

  after_create :create_unread_messages

  def full_name
    "#{self.given_name} #{self.family_name}"
  end

  def unsubscribe_push 
    self.update(push_p256dh: nil, push_auth: nil, push_url: nil)
  end

  def as_fhir_json(*args)
    return {
             givenName: given_name,
             familyName: family_name,
             identifier: [
               { value: id, use: "official" },
               { value: "test", use: "messageboard" },
             ],
             managingOrganization: managing_organization,

           }
  end

  def send_push_to_user(title, body, app_url = "/", type = nil)

    #Check to make sure their subscription information is up to date
    if (self.push_url.nil? || self.push_auth.nil? || self.push_p256dh.nil?)
      return
    end

    data = { url: app_url }

    if (!type.nil?)
      data[:type] = type
    end

    message = JSON.generate(
      title: "#{title}",
      body: "#{body}",
      url: "#{ENV["URL_CLIENT"]}",
      data: data,
    )

    begin
          Webpush.payload_send(
      message: message,
      endpoint: self.push_url,
      p256dh: self.push_p256dh,
      auth: self.push_auth,
      ttl: 24 * 60 * 60,
      vapid: {
        subject: "mailto:sender@example.com",
        public_key: ENV["VAPID_PUBLIC_KEY"],
        private_key: ENV["VAPID_PRIVATE_KEY"],
      })
    rescue => exception
      puts("User Push Info Was Probably Expired")
      puts(exception)
    end

  end

  def update_last_message_seen(channel_id, number)
    MessagingNotification.where(channel_id: channel_id, user_id: self.id).first.update(read_message_count: number)
  end

  def create_unread_messages
    Channel.where(is_private: false).map do |c|
        self.messaging_notifications.create!(channel_id: c.id, user_id: self.id, read_message_count: 0)
      end
  end

  def send_message_no_push(body, channel_id)
    one = self.messages.new(body: body, channel_id: channel_id)
    one.skip_notify = true
    one.save
  end

  def update_password(new_password_string)
    self.update(password_digest: BCrypt::Password.create(new_password_string))
  end

  def update_password_test
    params[:currentPassword]
  end

  def check_current_password(password)
    BCrypt::Password.new(self.password_digest) == password
  end

  def available_channels
    return self.channels
  end

end
