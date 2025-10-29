module Decidim
  module ParticipatoryProcessesExtended
    class Result < ApplicationRecord
      include Decidim::Traceable
      include Decidim::Loggable

      belongs_to :gallery,
                 class_name: "Decidim::Repository::Gallery",
                 optional: true

      belongs_to :participatory_space,
                 foreign_key: "decidim_participatory_space_id",
                 foreign_type: "decidim_participatory_space_type",
                 polymorphic: true

      scope :published, -> { where(published: true)}
      scope :sorted_by_weight, -> { order(:weight)}

      self.table_name = 'decidim_participatory_processes_extended_results'

      def self.log_presenter_class_for(_log)
        Decidim::ParticipatoryProcessesExtended::AdminLog::ResultPresenter
      end
    end
  end
end
