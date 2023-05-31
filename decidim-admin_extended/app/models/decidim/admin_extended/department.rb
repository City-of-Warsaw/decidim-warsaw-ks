# frozen_string_literal: true

module Decidim::AdminExtended
  # Departments are used to assign them to Processes and later to filter through them
  # on processes page. This is supposed to give users additional information,
  # about what part of the Organziation is responsible for given Process.
  class Department < ApplicationRecord
    include Decidim::Traceable
    include Decidim::Loggable

    belongs_to :organization,
               class_name: "Decidim::Organization",
               foreign_key: :organization_id

    # Presenter class for AdminLogs
    def self.log_presenter_class_for(_log)
      Decidim::AdminExtended::AdminLog::DepartmentPresenter
    end
  end
end
