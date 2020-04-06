require 'webpush'
class User < ApplicationRecord

    has_many :messages
    has_many :channels
    has_many :notifications

    has_many :daily_reports

    enum language: { en: 0, es: 1 }
    enum type: { Patient: 0, Practitioner: 1, Administrator: 2 }

    validates :password_digest, presence: true
    validates :email, uniqueness: true, allow_nil: true
    validates :phone_number, uniqueness: true, allow_nil: true

    after_create :create_notifications

    def as_fhir_json(*args)
      return {
        givenName: given_name,
        familyName: family_name,
        identifier: [
            {value: id,use: "official"},
            {value: "test",use: "messageboard"}
        ],
        treatmentStart: treatment_start,
        medicationSchedule: medication_schedule,
        managingOrganization: managing_organization
      }
    end

    def user_specific_channels
      #Modify this to attach a users notifications / push settings for each channel
      channelList = Channel.where(is_private: false).or(Channel.where(is_private: true, user_id: self.id)).sort_by &:created_at
    end

    def send_push_to_user(title, body)
      
      #Check to make sure their subscription information is up to date
      if(self.push_url.nil? || self.push_auth.nil? || self.push_p256dh.nil?)
        #render(json: { error: 'User has no push data' }, status: :unauthorized)
        #Dont send a notification
        return
      end

      message = JSON.generate(
        title: "#{title}",
        body: "#{body}",
        url: ENV['URL_CLIENT']
      )
      
      Webpush.payload_send(
        message: message,
        endpoint: self.push_url,
        p256dh: self.push_p256dh,
        auth: self.push_auth,
        ttl: 24 * 60 * 60,
        vapid: {
          subject: 'mailto:sender@example.com',
          public_key: ENV['VAPID_PUBLIC_KEY'],
          private_key: ENV['VAPID_PRIVATE_KEY']
        }
      )

    end

    def create_notifications
      Channel.all.map do |c| 
          if(!c.is_private || self.id == c.user_id)
              self.notifications.create!(channel_id: c.id, user_id: self.id, push_subscription: true )
          end
      end
  end
  
  end