class PhotoCodeSerializer < ActiveModel::Serializer
    attributes :id, :code, :title, :group_code, :group_id, :group_title

    def code
        object.full_code
    end

end