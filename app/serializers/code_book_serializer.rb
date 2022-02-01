class CodeBookSerializer < ActiveModel::Serializer
    has_many :codes
    has_many :groups
    has_many :colors
    has_many :versions
end