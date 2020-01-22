require 'aws-sdk'
class LabTest < ApplicationRecord

    def as_json(*args)

        signer = Aws::S3::Presigner.new
        tempURL = signer.presigned_url(:get_object, bucket: "lab-strips", key: photo_url)

        return{
          url: tempURL
        }
      end

end
  