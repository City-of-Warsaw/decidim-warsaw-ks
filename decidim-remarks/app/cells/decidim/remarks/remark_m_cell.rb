# frozen_string_literal: true

module Decidim
  module Remarks
    # This cell renders the Medium (:m) Remark card
    # for an given instance of a Remark
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

      def can_comment?
        !model.component.users_action_disallowed? || (model.component.users_action_disallowed? && current_user && current_user.has_ad_role?)
      end

      # Public method to pair remark with comment element
      def node_id
        "comments-for-Remark-#{model.id}-response"
      end

      def remark_token
        options[:remark_token]
      end

      def presenter
        Decidim::Remarks::RemarkPresenter
      end

      def flag_remark
        render
      end

      def show_comments
        cell(
          "decidim/remarks/comments",
          model,
          machine_translations: false,
          single_comment: params.fetch("commentId", nil),
          order: "older"
        ).to_s
      end

      def author_presenter
        if model.author.respond_to?(:official?) && model.author.official?
          Decidim::Debate::OfficialAuthorPresenter.new
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
        "/processes/#{model.participatory_space.slug}/f/#{model.component.id}/remarks/#{model.id}/edit"
      end

      private

      def creation_date
        l(model.created_at.to_date, format: :decidim_short)
      end

      def description
        decidim_sanitize simple_format(model.body, sanitize: true)
      end

      # def machine_translations_toggled?
      #   options[:machine_translations] == true
      # end

      def comments
        model.comments
      end
    end
  end
end
