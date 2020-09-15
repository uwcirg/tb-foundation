class MessageSerializer < ActiveModel::Serializer

    attributes :id, :user_id, :body, :created_at, :updated_at, :photo_url

    def photo_url
        if(!object.photo_path.nil?)
            return FileHandler.new(Message.photo_bucket,object.photo_path).get_presigned_download_url
        end
            return ""
    end

end