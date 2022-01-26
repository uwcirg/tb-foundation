class CodeBookSerializer < ActiveModel::Serializer
    has_many :codes
    has_many :groups
end