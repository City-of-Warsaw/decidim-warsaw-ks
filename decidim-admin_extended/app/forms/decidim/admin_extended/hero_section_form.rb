# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A form object to create and update Banned Word.
    class HeroSectionForm < Form
      attribute :title, String
      attribute :subtitle, String
      attribute :banner_img
      attribute :banner_img_alt, String

      mimic :hero_section

      validates :title, presence: true
    end
  end
end
