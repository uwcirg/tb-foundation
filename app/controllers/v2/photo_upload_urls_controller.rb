class V2::PhotoUploadUrlsController < UserController
    before_action :snake_case_params
    before_action :auth_user

    def create
        if(params[:type] == "messaging")
            generate_message_upload_url
        elsif(params[:type] == "test-strip-photo")
            generate_test_photo_url
        else
            render(json:{error: "Must have type parameter of messaging or test-photo"}, status: 422)
        end
    end
    
    private

    def generate_test_photo_url
        file_name = "strip-photo-#{SecureRandom.uuid}.jpeg"
        url = FileHandler.new("patient-test-photos",file_name).create_presigned_upload_url
        render(json: { "uploadURL": url, "fileName": file_name })
    end

    def message_upload_url
        channel = Channel.find(message_photo_upload_params[:channel_id])
        file_name = "c#{channel.id}_u#{@current_user.id}_m#{channel.messages_count + 1}_#{Time.now.to_i}.#{message_photo_upload_params[:file_type]}"
        url = FileHandler.new("messaging-photos",file_name).create_presigned_upload_url
        render(json: {url: url, path: file_name  }, status: :ok)
    end

    def message_photo_upload_params
        params.require(:type)
        params.permit(:channel_id,:file_type)
      end

end