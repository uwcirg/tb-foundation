class MessageSerializer < ActiveModel::Serializer

    attributes :id, :user_id, :user_type, :body, :created_at, :updated_at, :photo_url, :is_hidden

    def photo_url
        if(!object.photo_path.nil?)
            return FileHandler.new(Message.photo_bucket,object.photo_path).get_presigned_download_url
        end
            return ""
    end

    def user_type
        object.user.type
    end

end