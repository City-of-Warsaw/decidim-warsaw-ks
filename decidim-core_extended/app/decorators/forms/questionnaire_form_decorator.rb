# frozen_string_literal: true

require "valid_email2"

Decidim::Forms::QuestionnaireForm.class_eval do
  attribute :email, String

  validates :email, "valid_email_2/email": { disposable: true }, if: ->(form) { form.email.present? }

  # OVERWRITTEN
  # adds a custom separator to show user step 0 
  def responses_by_step
    @responses_by_step ||=
      begin
        steps = [[]] + responses.chunk_while do |a, b|
          !a.question.separator? || b.question.separator?
        end.to_a

        steps = [[]] if steps == []
        steps
      end
  end 
end
