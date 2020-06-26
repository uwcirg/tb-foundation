class ContactTracing < ApplicationRecord
    belongs_to :patient

    enum contacts_tested: { No: 0, Yes: 1, Some: 2 }

end
  