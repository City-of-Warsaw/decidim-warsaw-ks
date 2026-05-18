# frozen_string_literal: true

module Decidim
  module ExpertQuestions
    class UserQuestionLCell < Decidim::CardLCell
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

      def frontend_administrable?
        user_entity? &&
          model.can_be_administered_by?(current_user) &&
          (model.respond_to?(:official?) && !model.official?)
      end

      def has_answer?
        model.expert_answer&.published?
      end

      def user_question_token
        options[:user_question_token]
      end

      def presenter
        Decidim::ExpertQuestions::UserQuestionPresenter
      end

      def author_is_admin?
        model.author.is_a?(Decidim::User) && model.author.has_ad_role?
      end

      # TODO: needs refactoring
      # helpers loose component_id
      def edit_link
        "/processes/#{model.participatory_space.slug}/f/#{model.component.id}/user_questions/#{model.id}/edit"
      end

      # Public method to pair remark with comment element
      def node_id
        "comments-for-UserQuestion-#{model.id}-response"
      end

      private

      def title
        presenter.new(expert_name: model.expert.full_name).name
      end

      def description
        decidim_sanitize simple_format(model.body, sanitize: true)
      end

      def answer_body
        answer.body
      end

      def answer_files
        answer.files
      end

      def answer
        model.expert_answer
      end

      def init_expert_presenter
        Decidim::ExpertQuestions::ExpertPresenter.new(model.expert_answer.expert)
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

      def card_classes
        classes = ["card--#{dom_class(model)} commentable-root"]
      end

      # Gives colour to a comment whose author is an internal user - AD user
      def admin_response_class
        classes = []
        classes << "admin-response" if author_is_admin?
        classes.join(" ")
      end

      def user_entity?
        (model.respond_to?(:creator_author) && model.creator_author.respond_to?(:nickname)) ||
          (model.respond_to?(:author) && model.author.respond_to?(:nickname))
      end
    end
  end
end
