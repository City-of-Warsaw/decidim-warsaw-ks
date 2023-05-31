# frozen_string_literal: true

Decidim::Forms::UserAnswersSerializer.class_eval do
  include Decidim::TranslatableAttributes

  # Overwritten
  # Public: Exports a hash with the serialized data for the user answers,
  # add user data to surveys export
  def serialize
    @answers.each_with_index.inject({}) do |serialized, (answer, idx)|
      serialized.update(
        answer_translated_attribute_name(:id) => answer.session_token,
        answer_translated_attribute_name(:created_at) => answer.created_at.to_s(:db),
        answer_translated_attribute_name(:ip_hash) => answer.ip_hash,
        answer_translated_attribute_name(:user_status) => answer_translated_attribute_name(answer.decidim_user_id.present? ? "registered" : "unregistered"),
        "#{idx + 1}. #{translated_attribute(answer.question.body)}" => normalize_body(answer),
        answer_translated_attribute_name(:gender) => answer.user&.gender ? I18n.t("gender.#{answer.user.gender}", scope: "decidim.users") : '',
        answer_translated_attribute_name(:birth_year) => answer.decidim_user_id.present? ? answer.user.birth_year : '',
        answer_translated_attribute_name(:district) => answer.user&.district ? translated_attribute(answer.user.district.name) : ''
      )
    end
  end
end
