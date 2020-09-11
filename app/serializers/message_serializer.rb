class MessageSerializer < ActiveModel::Serializer

    # t.bigint "channel_id"
    # t.bigint "user_id", null: false
    # t.text "body", null: false
    # t.datetime "created_at", precision: 6, null: false
    # t.datetime "updated_at", precision: 6, null: false
    # t.string "photo_path"
    
    attributes :id, :user_id, :body, :created_at, :updated_at, :photo_url

    def photo_url
        if(!object.photo_path.nil?)
            return FileHandler.new(Message.photo_bucket,object.photo_path).get_presigned_download_url
        end
            return ""
    end

end