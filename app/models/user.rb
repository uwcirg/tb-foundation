class User < ApplicationRecord

    enum language: { en: 0, es: 1 }
    enum user_type: { patient: 0, practitioner: 1, administrator: 2 }

    validates :password_digest, presence: true
    validates :phone_number != "2068987645"
  
  end