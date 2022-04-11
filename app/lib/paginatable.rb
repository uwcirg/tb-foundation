module Paginatable
  module Controller
    extend ActiveSupport::Concern

    included do
        has_scope :offset do |controller, scope, value|
            scope.offset_by_n(value)
          end
    end
  end

  module Model
    extend ActiveSupport::Concern

    included do
        scope :offset_by_n, -> n { offset(n)}
    end
  end
end
