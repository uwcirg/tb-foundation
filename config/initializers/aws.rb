Aws.config.update({
  credentials: Aws::Credentials.new(ENV["MINIO_ACCESS_KEY"], ENV["MINIO_SECRET_KEY"]),
  endpoint: ENV["URL_MINIO"],
  force_path_style: true,
  region: "us-east-1"
})


DEFAULT_BUCKETS = ["patient-test-photos", "messaging-photos"]

s3 = Aws::S3::Client.new()

def bucket_exists(s3_client, bucket_name)
  response = s3_client.list_buckets
  response.buckets.each do |bucket|
    return true if bucket.name == bucket_name
  end
  return false
rescue StandardError => e
  puts "Error listing buckets: #{e.message}"
  return false
end


DEFAULT_BUCKETS.each do |bucket|
  begin
    already_exists = bucket_exists(s3,bucket)
    if(!already_exists)
      s3.create_bucket(bucket: bucket)
      print("Created default bucket #{bucket}")
    else
      #print("Bucket #{bucket} skipped because it already existed")
    end
  rescue
    print("Bucket #{bucket} already existed !!")
  end
end
