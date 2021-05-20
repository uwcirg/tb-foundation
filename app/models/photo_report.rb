class PhotoReport < ApplicationRecord
    belongs_to :daily_report, optional: true
    belongs_to :patient, :foreign_key=> :user_id

    def self.policy_class
        PatientRecordPolicy
      end

    def assigned_practitioner
        return self.user.practitioner_id
    end

    def approve(id)
        self.update(approved: true,practitioner_id: id, approval_timestamp: DateTime.now() )
        self.save
    end

    def deny(id)
        self.update(approved: false,practitioner_id: id, approval_timestamp: DateTime.now() )
        self.save
    end

    def get_url
        if(self.photo_url.nil?)
            tempURL = nil
        else
            signer = Aws::S3::Presigner.new
            tempURL = signer.presigned_url(:get_object, bucket: "patient-test-photos", key: photo_url)
        end

        return tempURL
    end

    def pretty_json
        return {
            url: get_url
          }
    end

  end
  