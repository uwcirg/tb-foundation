class CodeApplicationSerializer < ActiveModel::Serializer

    attributes :code, :group, :title, :photo_code_id, :id

    def code
        object.photo_code.full_code
    end

    def group
        object.photo_code.group_code
    end

    def title
        object.photo_code.title
    end

    def photo_code_id
        object.photo_code.id
    end
    
end