# frozen_string_literal: true

module Decidim::AdminExtended
  # Additional Translation model is used to manage specific translations like flashes, confirmations ect.
  class AdditionalTranslation < ApplicationRecord
    include Decidim::Traceable
    include Decidim::Loggable

    # special feature for additional managing translations from yaml->database
    self.table_name = "translations"
    serialize :value

    after_update :reload_translations

    def reload_translations
      I18n.backend.reload!
    end
    
    # Presenter class for AdminLogs
    def self.log_presenter_class_for(_log)
      Decidim::AdminExtended::AdminLog::AdditionalTranslationPresenter
    end
  end
end
