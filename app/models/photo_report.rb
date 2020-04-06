class PhotoReport < ApplicationRecord
    #belongs_to :daily_report
    has_one :user, through: :daily_report

    def get_url
        if(self.photo_url.nil?)
            tempURL = nil
        else
            signer = Aws::S3::Presigner.new
            tempURL = signer.presigned_url(:get_object, bucket: "patient-test-photos", key: photo_url)
        end

        return tempURL
    end
  end
  