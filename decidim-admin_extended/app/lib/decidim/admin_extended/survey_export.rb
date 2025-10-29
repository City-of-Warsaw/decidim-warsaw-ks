# frozen_string_literal: true

module Decidim
  module AdminExtended
    # This SurveyExport contains logic for surveys export in admin panel
    module SurveyExport
      include Decidim::TranslatableAttributes

      private

      def answers_for(questionnaire)
        answers_collection = Decidim::Forms::Answer.not_separator.joins(:question).where(questionnaire: questionnaire)
        answers_collection.sort_by { |answer| answer.question.position }
                          .group_by { |a| a.user || a.session_token }
                          .values.sort_by { |answers| answers.first.created_at }
      end

      # Pytania pojedynczego wyboru sa w jednej kolumne, dla matrix tez
      def survey_export_headers(questionnaire)
        arr = [
          'Lp.',
          'Data wypełnienia',
          answer_translated_attribute_name(:user_status)
        ]
        questionnaire.questions.not_separator.each_with_index do |question, idx|
          if question.matrix?
            question.matrix_rows.each do |matrix_row|
              if question.single_option?
                arr << "#{idx + 1}. #{question.translated_body} - #{translated_attribute(matrix_row.body)}"
              else
                question.answer_options.map do |answer_option|
                  arr << "#{idx + 1}. #{question.translated_body} - #{translated_attribute(matrix_row.body)} - #{answer_option.translated_body}"
                end
              end
            end
          elsif question.multiple_choice? && !question.single_option?
            question.answer_options.each do |answer_option|
              arr << "#{idx + 1}. #{question.translated_body} - #{answer_option.translated_body}"
            end
          else
            # for short_answer long_answer and single_option
            arr << "#{idx + 1}. #{question.translated_body}"
          end
        end
        arr << answer_translated_attribute_name(:gender)
        arr << answer_translated_attribute_name(:age)
        arr << answer_translated_attribute_name(:district)
        arr << 'Adres email'
        arr
      end

      def survey_answers_rows(questionnaire)
        answers_collection = answers_for(questionnaire)
        arr = []
        answers_collection.each_with_index do |answers, idx|
          arr << add_answer_row(questionnaire, answers, idx + 1)
        end
        arr
      end

      def add_answer_row(questionnaire, answers, idx)
        h = user_answers_hash(answers, idx)
        survey_export_columns(questionnaire).keys.each_with_object([]) do |key, arr|
          arr << h[key]
        end
      end

      def user_answers_hash(answers, idx)
        h = {}
        random_answer = answers.first
        h['lp'] = idx
        h['created_at'] = random_answer.created_at.in_time_zone("Warsaw").strftime("%Y-%m-%d %H:%M:%S").to_s
        h['user_status'] = answer_translated_attribute_name(random_answer.decidim_user_id.present? ? 'registered' : 'unregistered')
        h['gender'] = random_answer.user&.gender.present? ? I18n.t("gender.public_post.#{random_answer.user.gender}", scope: 'decidim.users') : ''
        # h['birth_year'] = (random_answer.decidim_user_id.present? ? random_answer.user.birth_year : '')
        h['age'] = random_answer.user&.birth_year.present? ? I18n.t("age.#{random_answer.user.age_range}", scope: 'decidim.comments') : ''
        h['district'] = (random_answer.user&.district ? translated_attribute(random_answer.user.district.name) : '')
        h['email'] = random_answer.questionnaire.emails_by_session_token[random_answer.session_token]

        answers.each do |answer|
          if answer.question.matrix?
            h.update(matrix_response_for(answer))
          elsif answer.question.multiple_choice? && !answer.question.single_option?
            h.update(choices_response_for(answer))
          else
            h["single-#{answer.question.id}"] = if answer.question.single_option?
                                                  # TODO check why choices can by nil/blank
                                                  [answer.choices&.first&.body, answer.choices&.first&.custom_body].compact.join(' - ')
                                                else
                                                  answer.body.presence || attachments_response_for(answer)
                                                end
          end
        end
        h
      end

      # collect all export headers keys with column size type
      def survey_export_columns(questionnaire)
        @survey_export_columns ||= begin
                                  arr = { 'lp' => 'lp', 'created_at' => 'default', 'user_status' => 'default' }
                                  questionnaire.questions.not_separator.each do |question|
                                    if question.matrix?
                                      question.matrix_rows.each do |matrix_row|
                                        if question.single_option?
                                          arr[matrix_row_key(matrix_row, nil)] = 'default'
                                        else
                                          question.answer_options.map do |answer_option|
                                            arr[matrix_row_key(matrix_row, answer_option)] = 'default'
                                          end
                                        end
                                      end
                                    elsif question.multiple_choice? && !question.single_option?
                                      question.answer_options.each do |answer_option|
                                        arr[multi_row_key(answer_option)] = 'default'
                                      end
                                    else
                                      arr["single-#{question.id}"] = 'long'
                                    end
                                  end
                                  arr['gender'] = 'default'
                                  arr['age'] = 'default'
                                  arr['district'] = 'default'
                                  arr['email'] = 'default'
                                  arr
                                end
      end

      # Public: Returns the width of a column based on the given type
      #
      # Parameters:
      #   key - A String specifying the type for the column.
      #
      # Returns:
      #   An Integer representing the width of the column.
      def column_width(key)
        case key
        when 'lp' then 5
        when 'long' then 35
        else
          20
        end
      end

      # Public: Returns an array of column widths for a given questionnaire.
      #
      # Parameters:
      #   questionnaire - The questionnaire object.
      #
      # Returns:
      #   An array of integers representing the widths of the columns.
      def column_widths(questionnaire)
        survey_export_columns(questionnaire).values.map { |key| column_width(key) }
      end

      # Build uniq key for each question-row in matrix, and for each answer in question-row
      # when it is possible to select multiple answers for one question-row
      def matrix_row_key(matrix_row, answer_option = nil)
        "matrix-#{matrix_row.question.id}-row-#{matrix_row.id}-opt-#{answer_option&.id}"
      end

      # Build uniq key for each answer in multi-question
      def multi_row_key(answer_option)
        "multi-#{answer_option.question.id}-opt-#{answer_option.id}"
      end

      def answer_translated_attribute_name(attribute)
        I18n.t(attribute.to_sym, scope: 'decidim.forms.user_answers_serializer')
      end

      def attachments_response_for(answer)
        answer.attachments.map(&:url).join('')
      end

      def choices_response_for(answer)
        h = {}
        answer.choices.each do |choice|
          h[multi_row_key(choice.answer_option)] = if choice.custom_body.present?
                                                     [choice.body, choice.custom_body].compact.join(' - ')
                                                   else
                                                     1
                                                   end
        end
        h
      end

      def matrix_response_for(answer)
        h = {}
        answer.choices.each do |choice|
          if answer.question.single_option?
            h[matrix_row_key(choice.matrix_row, nil)] = [choice.body, choice.custom_body].compact.join(' - ')
          else
            h[matrix_row_key(choice.matrix_row, choice.answer_option)] = if choice.custom_body.present?
                                                                           [choice.body, choice.custom_body].compact.join(' - ')
                                                                         else
                                                                           1
                                                                         end
          end
        end
        h
      end
    end
  end
end