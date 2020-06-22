class Organization < ApplicationRecord

    has_many :practitioners
    has_many :patients
        
end