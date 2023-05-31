# frozen-string_literal: true

module Decidim::ParticipatoryProcessesExtended
  class ParticipatoryProcessReportPublishedEvent < Decidim::Events::SimpleEvent
    include Rails.application.routes.mounted_helpers

    def resource_path
      @resource_path ||= decidim_participatory_processes.participatory_process_path(slug: participatory_space.slug)
    end

    def resource_url
      @resource_url ||= decidim_participatory_processes
                          .participatory_process_url(
                            slug: participatory_space.slug,
                            host: participatory_space.organization.host
                          )
    end

    def participatory_space
      # resource.participatory_process
      resource
    end
  end
end
