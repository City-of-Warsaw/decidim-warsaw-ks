# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A form object to create or update faq.
    class FaqForm < Form
      attribute :title, String
      attribute :content, String
      attribute :weight, Integer
      attribute :published, Boolean, default: false
      attribute :faq_group_id, Integer

      mimic :faq

      validates :title, :content, :weight, :faq_group_id, presence: true
      validates :published, inclusion: { in: [true, false] }
    end
  end
end
