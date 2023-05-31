# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A form object to create and update Tag.
    class TagForm < Form
      attribute :name, String

      mimic :tag

      validates :name, presence: true
    end
  end
end
