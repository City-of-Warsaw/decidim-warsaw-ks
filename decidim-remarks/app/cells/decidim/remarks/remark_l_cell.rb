# frozen_string_literal: true

module Decidim
  module Remarks
    class RemarkLCell < Decidim::CardLCell
      include Decidim::CoreExtended::AuthorForCells
      include Rails.application.routes.mounted_helpers
      include Decidim::Comments::CommentsHelper
      include ActionView::Helpers::DateHelper
      include Decidim::TooltipHelper
      include Decidim::LayoutHelper
      include Decidim::SearchesHelper

      def show
        render :show
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

      def author_is_admin?
        model.author.is_a?(Decidim::User) && model.author.has_ad_role?
      end

      # helpers loose component_id
      def edit_link
        "/processes/#{model.participatory_space.slug}/f/#{model.component.id}/remarks/#{model.id}/edit"
      end

      def allow_edit?(remark, user)
        remark.authored_by?(user) ||
          (!user_signed_in? && remark.author == Decidim::CoreExtended::UnregisteredAuthor.first && remark.allow_edition?(remark.token))
      end

      private

      def creation_date
        l(model.created_at.to_date, format: :decidim_short_cut_zero)
      end

      def description
        decidim_sanitize simple_format(model.body, sanitize: true)
      end

      def comments
        model.comments
      end

      def card_classes
        classes = ["card--#{dom_class(model)} commentable-root"] 
      end

      # Gives colour to a comment whose author is an internal user - AD user
      def admin_response_class
        classes = []
        classes << "admin-response" if author_is_admin?
      end
      # Used for voting for remark

      def votes_up_classes
        classes = ["button button__sm button__text-secondary js-remark__votes--up"]
        classes << "is-vote-selected" if voted_up?
        classes << "is-vote-notselected" if voted_down?
        classes.join(" ")
      end

      def votes_down_classes
        classes = ["button button__sm button__text-secondary js-remark__votes--down"]
        classes << "is-vote-selected" if voted_down?
        classes << "is-vote-notselected" if voted_up?
        classes.join(" ")
      end

      def voted_up?
        @up_voted ||= model.up_voted_by?(current_user)
      end

      def voted_down?
        @down_voted ||= model.down_voted_by?(current_user)
      end

      def up_votes_count
        model.up_votes.count
      end

      def down_votes_count
        model.down_votes.count
      end

      def vote_button_to(path, params, &)
        # actions are linked to objects belonging to a component
        # To apply :remark permission, the modal authorizer should be refactored to allow participatory spaces-level remarks
        return button_to(path, params, &) unless current_component

        action_authorized_button_to(:vote_remark, path, params, &)
      end
    end
  end
end
