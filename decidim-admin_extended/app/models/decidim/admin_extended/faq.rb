# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A Faq is used to add static content to the website, it can be useful so
    # organization can add their own popular and generic questions from users
    class Faq < ApplicationRecord
      include Decidim::Traceable
      include Decidim::Loggable
      include Decidim::Searchable

      belongs_to :faq_group,
                 class_name: "Decidim::AdminExtended::FaqGroup",
                 foreign_key: :faq_group_id

      scope :published, -> { where(published: true) }
      scope :sorted_by_weight, -> { order(:weight) }

      # Presenter class for AdminLogs
      def self.log_presenter_class_for(_log)
        Decidim::AdminExtended::AdminLog::FaqPresenter
      end
    end
  end
end
