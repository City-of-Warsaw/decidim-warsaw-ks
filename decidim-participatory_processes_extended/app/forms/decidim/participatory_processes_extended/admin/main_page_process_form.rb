# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessesExtended
    module Admin
      # A form object to create and update MainPageProcess
      class MainPageProcessForm < Form
        attribute :process, Decidim::ParticipatoryProcess
        attribute :process_id, Integer
        attribute :weight, Integer

        def map_model(model)
          super
          self.process = model
          self.process_id = model.id
          self.weight = model.main_page_weight
        end

        def participatory_processes_for_select
          Decidim::ParticipatoryProcess.not_on_main_page.map do |process|
            [
              process.title["pl"],
              process.id
            ]
          end
        end

        alias organization current_organization

        def persisted?
          process
        end
      end
    end
  end
end
