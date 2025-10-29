# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class RegisterUserCell < Decidim::ViewModel
      include Decidim::CardHelper

      def show
        render :show
      end

      private

      def header
        model.settings.header
      end

      def description
        model.settings.description
      end

      def action_title
        if model.settings.action_title.present?
          model.settings.action_title
        else
          t("decidim.shared.follow_modal.register")
        end
      end
    end
  end
end
