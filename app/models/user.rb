require 'webpush'
class User < ApplicationRecord

    has_many :messages
    has_many :channels

    enum language: { en: 0, es: 1 }
    enum type: { Patient: 0, Practitioner: 1, Administrator: 2 }

    validates :password_digest, presence: true
    validates :email, uniqueness: true, allow_nil: true
    validates :phone_number, uniqueness: true, allow_nil: true


    #Given a uuid, send a push to that user

    #TODO: Modify this code to not use Participant.find but to just use the values like in the participant controller

    def send_push_to_user(message)
      
      #Check to make sure their subscription information is up to date
      if(self.push_url.nil? || self.push_auth.nil? || self.push_p256dh.nil?)
        render(json: { error: 'User has no push data' }, status: :unauthorized)
        return
      end

      message = JSON.generate(
        title: "#{self.given_name} message",
        body: "#{self.given_name} Please Take Your Medication",
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
  
  end