# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A form object to create and update Department.
    class DepartmentForm < Form
      attribute :name, String

      mimic :department

      validates :name, presence: true
    end
  end
end
