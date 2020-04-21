class PhotoReport < ApplicationRecord
    belongs_to :daily_report, optional: true
    #has_one :daily_report

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
  