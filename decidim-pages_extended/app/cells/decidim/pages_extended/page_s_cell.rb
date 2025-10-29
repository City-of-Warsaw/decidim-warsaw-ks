# frozen_string_literal: true

module Decidim
  module PagesExtended
    # This cell renders the Search (:s) page card
    # for an given instance of a page
    # warning! this cell handle with component's object Decidim::Pages::Page
    class PageSCell < Decidim::CardSCell
      def show
        render :show
      end

      private

      def description
        text = if model.is_a?(Decidim::StaticPage)
                 model.content
               elsif model.is_a?(Decidim::Pages::Page)
                 model.body
               end
        processed_text = translated_attribute(text)
        decidim_sanitize(truncate(strip_tags(processed_text), length: 210))
      end

      def participatory_space_class_name
        model.component.participatory_space.class.model_name.human
      end

      def participatory_space_title
        decidim_escape_translated model.component.participatory_space.title
      end

      def participatory_space_path
        resource_locator(model.component.participatory_space).path
      end

      def resource_title
        if model.is_a?(Decidim::StaticPage)
          model.title
        elsif model.is_a?(Decidim::Pages::Page)
          model.title
        end
      end

      def resource_path
        if model.is_a?(Decidim::StaticPage)
          page_path(model)
        elsif model.is_a?(Decidim::Pages::Page)
          super # inherited from CardSCell
        end
      end
    end
  end
end
