# frozen_string_literal: true

module Decidim
  module CustomAi
    # A form object to create and update Tag.
    class TagForm < Form
      attribute :name, String

      mimic :tag

      validates :name, presence: true, length: { maximum: 200 }
      validate :uniq_tag_name

      private

      def uniq_tag_name
        unless Decidim::CustomAi::Tag.find_by(name: name.downcase, component:).nil?
          return errors.add(:name, "Podana nazwa juz istnieje") if id.nil?
          return errors.add(:name, "Podana nazwa juz istnieje") if Decidim::CustomAi::Tag.find_by(id:, name: name.downcase, component:).nil?
        end
      end
    end
  end
end
