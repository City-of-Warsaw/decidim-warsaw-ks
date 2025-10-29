# frozen_string_literal: true

module Decidim
  module UsersExtended
    module ApplicationHelper
      include TranslatableAttributes
      include ResourceHelper

      def resource_url(resource, options={})
        # We not using decidm proposals/consultation requests - for escape this link
        return "" if resource.nil? || resource.is_a?(Decidim::Proposals::Proposal) || resource.is_a?(Decidim::ConsultationRequests::ConsultationRequest)
        return Decidim::News::Engine.routes.url_helpers.news_path(resource, options) if resource.is_a?(Decidim::News::Information)

        resource_locator(resource).path(options)
      end

      def resource_title(resource)
        destination_resource = if resource.root_commentable.class.to_s == "Decidim::News::Information"
                                 resource.root_commentable
                                else
                                  resource.root_commentable&.participatory_space
                                end

        translated_attribute(destination_resource.try(:title) || destination_resource.try(:name))
      end

      def component_title(component)
        translated_attribute(component.try(:title) || component.try(:name))
      end

      def participatory_space_title(component)
        space = component.participatory_space
        translated_attribute(space.try(:title) || space.try(:name))
      end
      def component_description(component)
        if component.component.settings.help_section_visibility
          decidim_sanitize(component.component.settings.help_section_description, strip_tags: true).truncate(250)
        end
      end

      def component_source_name(component)
        t("#{component.component.manifest_name}.name", scope: "decidim.components").upcase
      end
    end
  end
end
