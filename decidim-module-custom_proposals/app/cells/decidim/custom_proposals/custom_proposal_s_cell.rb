# frozen_string_literal: true

require "cell/partial"

module Decidim
  module CustomProposals
    class CustomProposalSCell < Decidim::CardSCell
      def show
        render :show
      end

      private

      def description
        text = model.body

        decidim_sanitize(truncate(strip_tags(text), length: 210))
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
    end
  end
end
