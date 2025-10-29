# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A form object to create and update additional translations.
    class AdditionalTranslationForm < Form
      attribute :value, String
      attribute :key, String

      mimic :additional_translation

      validates :value, presence: true
    end
  end
end
