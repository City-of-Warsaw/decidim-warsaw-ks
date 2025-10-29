# frozen_string_literal: true

module Decidim::AdminExtended
  # Main Menu Item is used to manage public menu.
  # Removing or adding a new item, should be resolve by migration.
  class MainMenuItem < ApplicationRecord
    include Decidim::Traceable
    include Decidim::Loggable

    def self.find_item(label)
      # working for one language
      find_by(sys_name: label)
    end

    # Public: Presenter class for AdminLog
    def self.log_presenter_class_for(_log)
      Decidim::AdminExtended::AdminLog::MainMenuItemPresenter
    end
  end
end
