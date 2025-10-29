# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessesExtended
    module Admin
      # A form object to create and update MainPageProcess
      class ReportForm < Form
        attribute :participatory_process, Decidim::ParticipatoryProcess
        attribute :participatory_process_id, Integer
        attribute :report_publication_date, Date
        attribute :report_description, String

        validates :report_description, presence: true

        def map_model(model)
          super
          self.participatory_process = model
          self.participatory_process_id = model.id
        end

        def persisted?
          participatory_process
        end
      end
    end
  end
end
