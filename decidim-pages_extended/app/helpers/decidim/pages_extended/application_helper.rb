module Decidim
  module PagesExtended
    module ApplicationHelper
      include Rails.application.routes.mounted_helpers

      def index_pages_extended_path(current_component)
        case current_component.participatory_space.class.name
        when 'Decidim::ParticipatoryProcess'
          decidim_pages_extended.participatory_process_slug_pages_path(current_component.participatory_space.slug, current_component.id)
        when 'Decidim::Assembly'
          decidim_pages_extended.assembly_slug_pages_path(current_component.participatory_space.slug, current_component.id)
        else
          decidim_pages_extended.participatory_process_slug_pages_path(current_component.participatory_space.slug, current_component.id)
        end
      end

      def new_pages_extended_url(current_component)
        case current_component.participatory_space.class.name
        when 'Decidim::ParticipatoryProcess'
          decidim_pages_extended.new_participatory_process_slug_page_path(current_component.participatory_space.slug, current_component.id)
        when 'Decidim::Assembly'
          decidim_pages_extended.new_assembly_slug_page_path(current_component.participatory_space.slug, current_component.id)
        else
          decidim_pages_extended.new_participatory_process_slug_page_path(current_component.participatory_space.slug, current_component.id)
        end
      end

      def create_pages_extended_url(current_component)
        case current_component.participatory_space.class.name
        when 'Decidim::ParticipatoryProcess'
          decidim_pages_extended.participatory_process_slug_pages_path(current_component.participatory_space.slug, current_component.id)
        when 'Decidim::Assembly'
          decidim_pages_extended.assembly_slug_pages_path(current_component.participatory_space.slug, current_component.id)
        else
          decidim_pages_extended.participatory_process_slug_pages_path(current_component.participatory_space.slug, current_component.id)
        end
      end

      def edit_pages_extended_path(page, current_component)
        case current_component.participatory_space.class.name
        when 'Decidim::ParticipatoryProcess'
          decidim_pages_extended.edit_participatory_process_slug_page_path(current_component.participatory_space.slug, current_component.id, page.id)
        when 'Decidim::Assembly'
          decidim_pages_extended.edit_assembly_slug_page_path(current_component.participatory_space.slug, current_component.id, page.id)
        else
          decidim_pages_extended.edit_participatory_process_slug_page_path(current_component.participatory_space.slug, current_component.id, page.id)
        end
      end

      def edit_pages_extended_link(page, current_component)
        case current_component.participatory_space.class.name
        when 'Decidim::ParticipatoryProcess'
          icon_link_to "pencil", decidim_pages_extended.edit_participatory_process_slug_page_path(current_component.participatory_space.slug, current_component, page), t("actions.edit", scope: "decidim.pages"), class: "action-icon--edit"
        when 'Decidim::Assembly'
          icon_link_to "pencil", decidim_pages_extended.edit_assembly_slug_page_path(current_component.participatory_space.slug, current_component, page), t("actions.edit", scope: "decidim.pages"), class: "action-icon--edit"
        else
          icon_link_to "pencil", decidim_pages_extended.edit_participatory_process_slug_page_path(current_component.participatory_space.slug, current_component, page), t("actions.edit", scope: "decidim.pages"), class: "action-icon--edit"
        end
      end

      def update_pages_extended_url(page, current_component)
        pp_slug = current_component.participatory_space.slug
        case current_component.participatory_space.class.name
        when 'Decidim::ParticipatoryProcess'
          "/admin/participatory_processes/#{pp_slug}/f/#{current_component.id}/pages/#{page.id}"
        when 'Decidim::Assembly'
          "/admin/assemblies/#{pp_slug}/f/#{current_component.id}/pages/#{page.id}"
        else
          "/admin/participatory_processes/#{pp_slug}/f/#{current_component.id}/pages/#{page.id}"
        end
      end

      def destroy_pages_extended_link(page, current_component)
        case current_component.participatory_space.class.name
        when 'Decidim::ParticipatoryProcess'
          icon_link_to "circle-x", decidim_pages_extended.participatory_process_slug_page_path(current_component.participatory_space.slug, current_component, page), t("actions.destroy", scope: "decidim.pages"), method: :delete, class: "action-icon--remove", data: { confirm: t("actions.confirm_destroy", scope: "decidim.pages") }
        when 'Decidim::Assembly'
          icon_link_to "circle-x", decidim_pages_extended.assembly_slug_page_path(current_component.participatory_space.slug, current_component, page), t("actions.destroy", scope: "decidim.pages"), method: :delete, class: "action-icon--remove", data: { confirm: t("actions.confirm_destroy", scope: "decidim.pages") }
        else
          icon_link_to "circle-x", decidim_pages_extended.participatory_process_slug_page_path(current_component.participatory_space.slug, current_component, page), t("actions.destroy", scope: "decidim.pages"), method: :delete, class: "action-icon--remove", data: { confirm: t("actions.confirm_destroy", scope: "decidim.pages") }
        end
      end

      def publish_pages_extended_url(page, current_component)
        case current_component.participatory_space.class.name
        when 'Decidim::ParticipatoryProcess'
          decidim_pages_extended.publish_participatory_process_slug_page_path(current_component.participatory_space.slug, current_component, page)
        when 'Decidim::Assembly'
          decidim_pages_extended.publish_assembly_slug_page_path(current_component.participatory_space.slug, current_component, page)
        else
          decidim_pages_extended.publish_participatory_process_slug_page_path(current_component.participatory_space.slug, current_component, page)
        end
      end
    end
  end
end
