# frozen_string_literal: true

module Decidim
  module ConsultationMap
    # This cell renders the List (:l) remark card
    # for an given instance of a Remark
    class RemarkLCell < Decidim::CardLCell
      include Decidim::CoreExtended::AuthorForCells
      include Rails.application.routes.mounted_helpers
      include Decidim::Comments::CommentsHelper
      include ActionView::Helpers::DateHelper

      def show
        render "show" 
      end

      def remark_token
        options[:remark_token]
      end

      def presenter
        Decidim::ConsultationMap::RemarkPresenter
      end

      def flag_remark
        render
      end

      def category
        @category ||= model.category
      end

      def images
        @images ||= model.images
      end

      def author_is_admin?
        model.author.is_a?(Decidim::User) && model.author.has_ad_role?
      end

      # helpers loose component_id
      def edit_link
        "/processes/#{ model.participatory_space.slug }/f/#{ model.component.id }/remarks/#{ model.id }/edit"
      end

      private

      def description
        decidim_sanitize simple_format(model.body, sanitize: true)
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

      # Public method to pair map remark with comment element
      def node_id
        "comments-for-Remark-#{model.id}-response"
      end

      def card_classes
        ["card--#{dom_class(model)} commentable-root"]
      end

      # Gives colour to a comment whose author is an internal user - AD user
      def admin_response_class
        classes = []
        classes << "admin-response" if author_is_admin?
      end
    end
  end
end
