class Expert < User

    validates :type, inclusion: { in: ["Expert"] }
    validates :email, presence: true

    # def available_channels
    #     return Channel.joins(:user).where(is_private: true, users: { type: "Practitioner" }).or(Channel.joins(:user).where(is_private: false)).order(:created_at)
    # end

end