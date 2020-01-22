Aws.config.update({
    credentials: Aws::Credentials.new(ENV['MINIO_ACCESS_KEY'], ENV['MINIO_SECRET_KEY']),
    endpoint: ENV['URL_MINIO'],
    force_path_style: true,
    region: 'us-east-1'
  })

LAB_BUCKET = Aws::S3::Resource.new.bucket("lab-test-images")
