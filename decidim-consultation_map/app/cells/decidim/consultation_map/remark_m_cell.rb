# frozen_string_literal: true

module Decidim
  module ConsultationMap
    # This cell renders the Medium (:m) debate card
    # for an given instance of a Debate
    class RemarkMCell < Decidim::CardMCell
      include Rails.application.routes.mounted_helpers
      include Decidim::Comments::CommentsHelper
      include ActionView::Helpers::DateHelper

      def show
        render search_controller? ? 'show_in_search' : 'show'
      end

      def has_comments?
        model.comments.any?
      end

      def search_controller?
        controller.class.name == "Decidim::SearchesController"
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

      def show_comments
        cell(
          "decidim/consultation_map/comments",
          model,
          machine_translations: false,
          single_comment: params.fetch("commentId", nil),
          order: "older"
        ).to_s
      end

      def category
        @category ||= model.category
      end

      def images
        @images ||= model.images
      end

      def images_alt
        model.alt.presence || "#{t("activemodel.attributes.remark.images")} - #{images}"
      end

      def author_presenter
        if model.author.respond_to?(:official?) && model.author.official?
          Decidim::Debates::OfficialAuthorPresenter.new
        elsif model.respond_to?(:unregistered_author?) && model.unregistered_author?
          model.signature.present? ? Decidim::CommentsExtended::UnregisteredAuthorPresenter.new(name_param: 'signed', signature: model.signature) : Decidim::CommentsExtended::UnregisteredAuthorPresenter.new
        elsif model.author.respond_to?(:has_ad_role?) && model.author.has_ad_role?
          Decidim::CommentsExtended::UnregisteredAuthorPresenter.new(name_param: 'ad_user_remark')
        elsif model.user_group
          model.user_group.presenter
        else
          model.author.presenter
        end
      end

      def author_is_admin?
        model.author.is_a?(Decidim::User) && model.author.has_ad_role?
      end

      # TODO: needs refactoring
      # helpers loose component_id
      def edit_link
        "/processes/#{ model.participatory_space.slug }/f/#{ model.component.id }/remarks/#{ model.id }/edit"
      end

      private

      def description
        decidim_sanitize simple_format(model.body, sanitize: true)
      end

      def comments
        model.comments
      end
    end
  end
end
