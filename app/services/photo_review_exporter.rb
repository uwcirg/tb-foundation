class PhotoReviewExporter

  def run
    photo_codes = PhotoCode.all
    all_reviews = PhotoReview.all.includes(:photo_report,:test_strip_version,:test_color).map {
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
        "reviewing_provider_id": review.photo_report.practitioner_id
      }

      photo_codes.each{
       |code|
       hash[code.display_name] = review.photo_codes.pluck(:id).include?(code.id)
      }

      hash
    }

    puts(all_reviews.last)
  end
end
