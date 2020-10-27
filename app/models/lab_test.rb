require 'aws-sdk-s3'
class LabTest < ApplicationRecord

    def as_json(*args)

        signer = Aws::S3::Presigner.new
        tempURL = signer.presigned_url(:get_object, bucket: "lab-strips", key: photo_url)

        return{

          url: tempURL,
          testID: self.test_id,
          description: self.description,
          photoURL: self.photo_url,
          isPositive: self.is_positive,
          testWasRun: self.test_was_run,
          minutesSince: self.minutes_since_test,
          createdAt: self.created_at 
        }
      end

end
  