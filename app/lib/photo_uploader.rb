require "aws-sdk-s3"
#To test this code - check this out https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/ClientStubs.html
#Allows you to mock input - seems like overkill for now

class PhotoUploader
  def initialize(bucket_name,file_name)
    @bucket = Aws::S3::Resource.new.bucket(bucket_name)
    raise ArgumentError, "Specified bucket does not exist. please create it" unless @bucket.exists?
    @object = @bucket.object("#{file_name}.jpeg")
    raise ArgumentError, "An object with that name already exists, use another name." if @object.exists?
  end

  def create_presigned_url
    url = @object.presigned_url(:put)
  end

end
