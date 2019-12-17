require 'webpush'
class User < ApplicationRecord

    has_many :messages
    has_many :channels

    enum language: { en: 0, es: 1 }
    enum type: { Patient: 0, Practitioner: 1, Administrator: 2 }

    validates :password_digest, presence: true
    validates :email, uniqueness: true, allow_nil: true
    validates :phone_number, uniqueness: true, allow_nil: true


    def as_json(*args)
      {
        id: id,
        name: given_name
      }

    end

    #Given a uuid, send a push to that user

    #TODO: Modify this code to not use Participant.find but to just use the values like in the participant controller

    # def send_push_to_user
    #   user = Participant.find(params[:uuid]);

    #   #Check to make sure their subscription information is up to date
    #   if(user.push_url.nil? || user.push_auth.nil? || user.push_p256dh.nil?)
    #     render(json: { error: 'user has no push data' }, status: :unauthorized)
    #     return
    #   end

    #   message = JSON.generate(
    #     title: params[:message],
    #     body: "name: #{user.name} uuid: #{user.uuid}",
    #     icon: "https://images.idgesg.net/images/article/2019/04/google-shift-100794036-large.jpg",
    #     url: "https://tb-app.cirg.washington.edu"
    #   )
      
    #   Webpush.payload_send(
    #     message: message,
    #     endpoint: user.push_url,
    #     p256dh: user.push_p256dh,
    #     auth: user.push_auth,
    #     ttl: 24 * 60 * 60,
    #     vapid: {
    #       subject: 'mailto:sender@example.com',
    #       public_key: "BMSAvU3i4-87WUvEFijxz-sNq7255ACiF8ubt2196lWu9l0U2eLqXeLt-8ZVUXt4djlQyiiJul23VVt7giO1d_U=",
    #       private_key: "iE2ZXg3t_IaZrm2noz2Z8uW_N0kgea9oVacU-8uXRGg="
    #     }
    #   )

    # end
  
  end