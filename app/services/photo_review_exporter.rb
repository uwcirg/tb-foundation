require "csv"
require "tempfile"

class PhotoReviewExporter
  CSV_BUCKET = "csv-exports"

  def initialize
    @s3 = Aws::S3::Client.new()
    @reports = PhotoReview.all.includes(:photo_report, :test_strip_version, :test_color)
    @hashed_reviews = generate_hash(@reports)
  end

  def to_csv
    temp_file = Tempfile.new("photo_review_csv_export")
    CSV.generate(headers: true) do |csv|
      CSV.open(temp_file, "w", write_headers: true, headers: column_names) do |writer|
        @hashed_reviews.each do |review|
          writer << review.values
        end
      end
    end

    create_bucket_if_not_exists

    begin
      file_name = "photo_reports_csv_#{Time.now.to_i}.csv"
      @s3.put_object(bucket: CSV_BUCKET, key: file_name, body: temp_file)
      url = Aws::S3::Resource.new.bucket(CSV_BUCKET).object(file_name).presigned_url(:get)

      puts("URL to access your report: ")
      puts(url)
    rescue StandardError => e
      puts("There was an error uploading your file")
      puts(e)
    end
  end

  private

  def create_bucket_if_not_exists
    @s3.create_bucket(bucket: CSV_BUCKET) if !bucket_exists(@s3, CSV_BUCKET)
  end

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

  def object_uploaded?(s3_client, bucket_name, object_key)
    response = s3_client.put_object(
      bucket: bucket_name,
      key: object_key,
    )
    if response.etag
      return true
    else
      return false
    end
  rescue StandardError => e
    puts "Error uploading object: #{e.message}"
    return false
  end

  def column_names
    @hashed_reviews[0].keys
  end

  def generate_hash(reviews)
    photo_codes = PhotoCode.all
    reviews.map {
      |review|
      hash = {
        "photo_report_id": review.photo_report.id,
        "photo_request_date": review.photo_report.date,
        "photo_submited_at": review.photo_report.created_at,
        "is_back_submission": review.photo_report.back_submission,
        "is_redo_for_previous_submission": !review.photo_report.redo_for_report_id.nil?,
        "patient_id": review.photo_report.user_id,
        "test_strip_version": review.test_strip_version&.version,
        "test_strip_id_number": review.test_strip_id,
        "photo_file_name": review.photo_report.photo_url,
        "provider_review_coding": review.photo_report.approved,
        "provider_flagged_for_redo": review.photo_report.redo_flag,
        "provider_review_created_at": review.photo_report.approval_timestamp,
        "engineer_review_test_coding": review.test_line_review ? "positive" : "negative",
        "engineer_review_control_coding": review.control_line_review,
        "engineer_review_test_area_color": review.control_color&.name,
        "engineer_review_control_area_color": review.test_color&.name,
        "reviewing_engineer_id": review.bio_engineer_id,
        "reviewing_provider_id": review.photo_report.practitioner_id,
      }

      photo_codes.each {
        |code|
        hash[code.display_name] = review.photo_codes.pluck(:id).include?(code.id)
      }
      hash
    }
  end
end
