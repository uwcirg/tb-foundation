class PhotoCodeSerializer < ActiveModel::Serializer
    attributes :id, :code, :title

    def code
        object.full_code
    end
end