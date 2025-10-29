# frozen_string_literal: true

# Decidim::ExpertQuestions::UserQuestionXlsSerializer

module Decidim
  module ExpertQuestions
    # Serializes a user question to export it in XLS format.
    class UserQuestionXlsSerializer
      include Decidim::TranslatableAttributes

      def initialize; end

      def headers
        columns_order.map { |column| columns_definition[column][:name] }
      end

      # Public: Get the order of columns for serializing a user question.
      # Returns an Array of symbols representing the column order.
      def columns_order
        %i[lp body url author_name email district age gender status created_at answered_at expert_name answer_body is_published]
      end

      def columns_definition
        {
          lp: { name: column_name_translation('lp'), size: :lp },
          body: { name: column_name_translation('body'), size: :body },
          url: { name: column_name_translation('url'), size: :url },
          author_name: { name: column_name_translation('author_name'), size: :default },
          email: { name: column_name_translation('email'), size: :default },
          district: { name: column_name_translation('district'), size: :default },
          age: { name: column_name_translation('age'), size: :auto },
          gender: { name: column_name_translation('gender'), size: :auto },
          status: { name: column_name_translation('status'), size: :auto },
          created_at: { name: column_name_translation('created_at'), size: :auto },
          answered_at: { name: column_name_translation('answered_at'), size: :default },
          expert_name: { name: column_name_translation('expert_name'), size: :default },
          answer_body: { name: column_name_translation('answer_body'), size: :body },
          is_published: { name: column_name_translation('is_published'), size: :default }
        }
      end

      def columns_widths
        columns_order.map { |column| column_width(columns_definition[column][:size]) }
      end

      # Public: Serializes an array of user questions into an array of serialized hashes,
      #
      # @param user_questions [Array] An array of user question objects to serialize.
      # @return [Array] An array of serialized user question hashes
      def serialize_all_with_files(user_questions)
        user_questions.flat_map.with_index(1) do |user_question, index|
          serialize_for_files(user_question, index)
        end
      end

      # Serializes a user question object into a hash, create additional hash objects for any files
      #
      # @param user_question [Object] The user question object to serialize.
      # @param index [Integer] The index of the user question in the array.
      # @return [Hash] for serialized user question hash without files, or [Array] of hashes for user question with files
      def serialize_for_files(user_question, index)
        if user_question.files.none?
          user_question_attrs(user_question, index)
        else
          user_question.files.map.with_index(1) do |file, subindex|
            user_question_attrs(user_question, [index, subindex].join('.')).tap do |attrs|
              attrs[:url] = file_url(file, user_question.organization.host)
            end
          end
        end
      end

      # Serializes a user question object into a hash, with optional additional attributes.
      #
      # @param user_question [Object] The user question object to serialize.
      # @param index [Integer] The index of the user question in the array.
      # @return [Hash] The serialized user question hash.
      def user_question_attrs(user_question, index)
        {
          lp: index,
          body: user_question.body,
          url: nil,
          author_name: user_question.author.is_a?(Decidim::User) ? user_question.author.name : I18n.t("decidim.comments_extended.models.comment.fields.unregistered_author"),
          email: user_question.email,
          district: translated_attribute(user_question.district&.name),
          age: user_question.age.present? ? I18n.t("age.#{user_question.age}", scope: "decidim.comments") : nil,
          gender: user_question.gender.present? ? I18n.t("gender.public_post.#{user_question.gender}", scope: "decidim.users") : nil,
          status: I18n.t("models.user_question.fields.statuses.#{user_question.status}", scope: "decidim.expert_questions"),
          created_at: I18n.l(user_question.created_at, format: :short),
          answered_at: user_question.expert_answer ? I18n.l(user_question.expert_answer.created_at, format: :short) : nil,
          expert_name: user_question.expert.full_name,
          answer_body: user_question.expert_answer&.body,
          is_published: user_question.expert_answer&.published? ? 'Tak' : 'Nie'
        }
      end

      # Returns an array of values from the given attributes hash,
      # in the order specified by the columns_order method.
      #
      # @param attrs [Hash] The user_question attributes hash
      # @return [Array] serialized array from user_question attrs
      def ordered_values(attrs)
        columns_order.map { |column| attrs[column] }
      end

      private

      def column_name_translation(column)
        I18n.t(column, scope: 'decidim.expert_questions.export.user_question')
      end

      def column_width(key)
        case key
        when :auto then nil
        when :lp then 5
        when :body then 40
        when :url then 70
        else
          20
        end
      end

      def file_url(file, host)
        Rails.application.routes.url_helpers.rails_blob_url(file, host: host)
      end
    end
  end
end