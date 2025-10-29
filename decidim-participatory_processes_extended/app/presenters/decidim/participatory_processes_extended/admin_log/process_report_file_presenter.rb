# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessesExtended
    module AdminLog
      class ProcessReportFilePresenter < Decidim::Log::BasePresenter
        #
        # def present
        #   present_space
        # end

        private

        # def present_space
        #   return h.content_tag(:span, "W procesie partycypacyjnym", class: "logs__log__space") if action_log.resource.nil? || action_log.resource.participatory_process.nil?
        #
        #   h.link_to(action_log.resource.participatory_process.title["pl"], space_path, class: "logs__log__space")
        # end
        def present_space_name
          h.translated_attribute action_log.resource.participatory_process.title
        end

        def space_path
          Decidim::ResourceLocatorPresenter.new(action_log.resource.participatory_process).path
        end

        def diff_fields_mapping
          {
            name: :string,
            file: :string,
            weight: :integer,
            published: :boolean
          }
        end

        def action_string
          case action
          when "create", "delete", "update"
            "decidim.admin_log.report_file.#{action}"
          else
            super
          end
        end

        def diff_actions
          super + %w(delete)
        end
      end
    end
  end
end
