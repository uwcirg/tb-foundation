class PhotoReport < ApplicationRecord
    belongs_to :daily_report, optional: true
    belongs_to :user
    #has_one :daily_report

    def assigned_practitioner
        return self.user.practitioner_id
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
  