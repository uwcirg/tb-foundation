class PhotoUploadController < UserController
    before_action :snake_case_params
    before_action :auth_user
    
    def message_upload_url
        channel = Channel.find(upload_params[:channel_id])
        file_name = "c#{channel.id}_u#{@current_user.id}_m#{channel.messages_count + 1}_#{Time.now.to_i}.#{upload_params[:file_type]}"
        url = FileHandler.new("messaging-photos",file_name).create_presigned_upload_url
        render(json: {url: url, path: file_name  }, status: :ok)
    end

    private

    def upload_params
        params.permit(:channel_id,:file_type)
      end

end