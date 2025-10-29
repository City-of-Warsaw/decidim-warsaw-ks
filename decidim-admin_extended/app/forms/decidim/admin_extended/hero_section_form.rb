# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A form object to create and update Banned Word.
    class HeroSectionForm < Form
      include Decidim::HasUploadValidations

      attribute :title, String
      attribute :description, String

      mimic :hero_section

      validates :title, presence: true
    end
  end
end
