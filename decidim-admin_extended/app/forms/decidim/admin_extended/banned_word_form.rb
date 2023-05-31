# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A form object to create and update Banned Word.
    class BannedWordForm < Form
      attribute :name, String

      mimic :banned_word

      validates :name, presence: true
    end
  end
end
