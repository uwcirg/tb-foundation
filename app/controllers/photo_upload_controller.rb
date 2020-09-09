class PhotoUploadController < UserController
    before_action :snake_case_params
    before_action :auth_user
    
    def message_upload_url
        channel = Channel.find(params[:channel_id])
        file_name = "c#{channel.id}_u#{@current_user.id}_m#{channel.messages_count}_#{Time.now.to_i}"
        url = PhotoUploader.new("messaging-photos",file_name).create_presigned_url
        render(json: {url: url }, status: :ok)
    end

    private

    def check_channel_id_present
        params.permit(:channel_id)
      end

end