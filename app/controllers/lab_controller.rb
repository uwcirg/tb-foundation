class LabController < UserController

  def upload_lab_test
    newTest = LabTest.create!(
      test_id: params[:testId],
      description: params[:description],
      photo_url: params[:photoURL],
      is_positive: params[:isPositive],
      test_was_run: params[:testWasRun],
      minutes_since_test: params[:minutesSinceTest],
    )

    signer = Aws::S3::Presigner.new
    url = signer.presigned_url(:get_object, bucket: "lab-strips", key: newTest.photo_url)

    render(json: newTest.as_json, status: 200)
  end
end
