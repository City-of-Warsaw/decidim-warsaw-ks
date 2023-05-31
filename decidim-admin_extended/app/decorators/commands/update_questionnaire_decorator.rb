# frozen_string_literal: true

Decidim::Forms::Admin::UpdateQuestionnaire.class_eval do
  private

  # Overwritten - added file_id and gallery_id
  def update_questionnaire_question(form_question)
    question_attributes = {
      body: form_question.body,
      description: form_question.description,
      position: form_question.position,
      mandatory: form_question.mandatory,
      question_type: form_question.question_type,
      max_choices: form_question.max_choices,
      max_characters: form_question.max_characters,
      file_id: form_question.file_id,
      gallery_id: form_question.gallery_id
    }

    update_nested_model(form_question, question_attributes, @questionnaire.questions) do |question|
      form_question.answer_options.each do |form_answer_option|
        answer_option_attributes = {
          body: form_answer_option.body,
          free_text: form_answer_option.free_text
        }

        update_nested_model(form_answer_option, answer_option_attributes, question.answer_options)
      end

      form_question.display_conditions.each do |form_display_condition|
        type = form_display_condition.condition_type

        display_condition_attributes = {
          condition_question: form_display_condition.condition_question,
          condition_type: form_display_condition.condition_type,
          condition_value: type == "match" ? form_display_condition.condition_value : nil,
          answer_option: %w(equal not_equal).include?(type) ? form_display_condition.answer_option : nil,
          mandatory: form_display_condition.mandatory
        }

        next if form_display_condition.deleted? && form_display_condition.id.blank?

        update_nested_model(form_display_condition, display_condition_attributes, question.display_conditions)
      end

      form_question.matrix_rows.each do |form_matrix_row|
        matrix_row_attributes = {
          body: form_matrix_row.body
        }

        update_nested_model(form_matrix_row, matrix_row_attributes, question.matrix_rows)
      end
    end
  end

  # Overwritten - added file_id and gallery_id
  def update_questionnaire
    @questionnaire.update!(title: @form.title,
                           description: @form.description,
                           tos: @form.tos,
                           file_id: @form.file_id,
                           gallery_id: @form.gallery_id)
  end
end
