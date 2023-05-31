# frozen_string_literal: true

module Decidim::AdminExtended
  # Tags are used for users interests.
  # For this Project, Areas are used as labels for the Participatory spaces, Tags on the other hand
  # will provide the logic to map Users interests and accordingly provide them with notifications
  # and newsletters.
  #
  # In future, Tags will be used to map Users interests with Warsaw's city info apps for Users' convenience.
  class Tag < ApplicationRecord
    include Decidim::Traceable
    include Decidim::Loggable

    belongs_to :organization,
               class_name: "Decidim::Organization",
               foreign_key: :organization_id

    has_many :process_tags,
              class_name: "Decidim::ParticipatoryProcessesExtended::ProcessTag",
              foreign_key: :decidim_admin_extended_tag_id,
              dependent: :destroy
    
    has_many :participatory_processes,
              through: :process_tags,
              class_name: "Decidim::ParticipatoryProcess",
              source: :participatory_process

    # Presenter class for AdminLogs
    def self.log_presenter_class_for(_log)
      Decidim::AdminExtended::AdminLog::TagPresenter
    end
  end
end
