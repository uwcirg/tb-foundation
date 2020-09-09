Aws.config.update({
  credentials: Aws::Credentials.new(ENV["MINIO_ACCESS_KEY"], ENV["MINIO_SECRET_KEY"]),
  endpoint: ENV["URL_MINIO"],
  force_path_style: true,
  region: "us-east-1",
})

DEFAULT_BUCKETS = ["patient-test-photos", "messaging-photos"]

s3 = Aws::S3::Client.new()

DEFAULT_BUCKETS.each do |bucket|
  begin
    s3.create_bucket(bucket: bucket)
    print("Created default bucket #{bucket}")
  rescue
    print("Bucket #{bucket} already existed")
  end
end
