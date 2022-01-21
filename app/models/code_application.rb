class CodeApplication < ApplicationRecord
    belongs_to :bio_engineer
    belongs_to :photo_report
    belongs_to :photo_code

end