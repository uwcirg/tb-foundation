class CodeApplicationSerializer < ActiveModel::Serializer

    attributes :code, :group, :title

    def code
        object.photo_code.full_code
    end

    def group
        object.photo_code.group_code
    end

    def title
        object.photo_code.title
    end
    
end