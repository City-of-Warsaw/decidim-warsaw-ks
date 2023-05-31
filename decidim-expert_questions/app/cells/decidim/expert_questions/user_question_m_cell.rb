# frozen_string_literal: true

module Decidim
  module ExpertQuestions
    # This cell renders the Medium (:m) UserQuestion card
    # for an given instance of a UserQuestion
    class UserQuestionMCell < Decidim::CardMCell
      include Rails.application.routes.mounted_helpers
      include Decidim::Comments::CommentsHelper
      include ActionView::Helpers::DateHelper

      def render_space?
        true
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

      def flag_question
        render
      end

      def show_comments
        cell(
          "decidim/expert_questions/comments",
          model,
          machine_translations: false,
          single_comment: params.fetch("commentId", nil),
          order: "older"
        ).to_s
      end

      def author_presenter
        if model.author.respond_to?(:official?) && model.author.official?
          Decidim::Debates::OfficialAuthorPresenter.new
        elsif model.respond_to?(:unregistered_author?) && model.unregistered_author?
          model.signature.present? ? Decidim::CommentsExtended::UnregisteredAuthorPresenter.new(name_param: 'signed', signature: model.signature) : Decidim::CommentsExtended::UnregisteredAuthorPresenter.new
        elsif model.author.respond_to?(:has_ad_role?) && model.author.has_ad_role?
          Decidim::CommentsExtended::UnregisteredAuthorPresenter.new(name_param: 'ad_user_question')
        elsif model.user_group
          model.user_group.presenter
        else
          model.author.presenter
        end
      end

      def node_id
        "comments-for-UserQuestion-#{model.id}-response"
      end

      # TODO: needs refactoring
      # helpers loose component_id
      def edit_link
        "/processes/#{ model.participatory_space.slug }/f/#{ model.component.id }/user_questions/#{ model.id }/edit"
      end

      private

      def title
        presenter.new(expert_name: model.expert.position_and_name).name
      end

      def description
        decidim_sanitize(model.body)
      end

      def answer_body
        answer.body
      end

      def answer_files
        answer.files
      end

      # def body
      #   decidim_sanitize(present(model).description)
      # end

      def answer
        model.expert_answer
      end

      def answer_published_date
        l answer.published_at, format: :decidim_short_no_time
      end

      def init_expert_presenter
        Decidim::ExpertQuestions::ExpertPresenter.new(model.expert_answer.expert)
      end
    end
  end
end
