# frozen_string_literal: true

module Decidim::AdminExtended
  class MainMenuItem < ApplicationRecord
    include Decidim::Traceable
    include Decidim::Loggable

    def self.find_item(label)
      # working for one language
      find_by(sys_name: label)
    end

    def self.create_missing_item(label)
      return if label == 'Zespoły' || label == 'Assemblies'

      self.create(sys_name: label, name: label, weight: self.all.count + 1) unless find_item(label)
    end

    # Public: Presenter class for AdminLog
    def self.log_presenter_class_for(_log)
      Decidim::AdminExtended::AdminLog::MainMenuItemPresenter
    end
  end
end
