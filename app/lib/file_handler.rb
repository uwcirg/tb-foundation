require "aws-sdk-s3"
#To test this code - check this out https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/ClientStubs.html
#Allows you to mock input - seems like overkill for now

class FileHandler

  def initialize(bucket_name,file_name)
    @bucket = Aws::S3::Resource.new.bucket(bucket_name)
    raise ArgumentError, "Specified bucket does not exist. please create it" unless @bucket.exists?
    @object = @bucket.object("#{file_name}")
  end

  def create_presigned_upload_url
    raise ArgumentError, "An object with that name already exists, use another name." if @object.exists?
    url = @object.presigned_url(:put)
  end

  def get_presigned_download_url
    raise ArgumentError, "No object with that name exists" unless @object.exists?
    url = @object.presigned_url(:get)
  end

end
