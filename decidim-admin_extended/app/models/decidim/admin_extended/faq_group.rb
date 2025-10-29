# frozen_string_literal: true

module Decidim
  module AdminExtended
    # Faq Group groups faqs
    class FaqGroup < ApplicationRecord
      include Decidim::Traceable
      include Decidim::Loggable

      has_many :faqs,
               class_name: "Decidim::AdminExtended::Faq",
               foreign_key: :faq_group_id,
               dependent: :destroy

      scope :published, -> { where(published: true) }
      scope :sorted_by_weight, -> { order(:weight) }

      # Presenter class for AdminLogs
      def self.log_presenter_class_for(_log)
        Decidim::AdminExtended::AdminLog::FaqGroupPresenter
      end
    end
  end
end
