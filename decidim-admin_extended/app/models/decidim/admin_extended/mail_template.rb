# frozen_string_literal: true

module Decidim::AdminExtended
  # MaiTemplate are used to handle customized email messages
  class MailTemplate < ApplicationRecord
    include Decidim::Traceable
    include Decidim::Loggable

    scope :sorted_by_name, -> { order(:name) }

    def filled_in?
      subject.present? && body.present?
    end

    # Presenter class for AdminLogs
    def self.log_presenter_class_for(_log)
      Decidim::AdminExtended::AdminLog::MailTemplatePresenter
    end

    def active?
      active
    end
  end
end
