# frozen_string_literal: true
require 'obscenity/active_model'

Decidim::Forms::AnswerForm.class_eval do
  validates :body, obscenity: { message: :banned_word }, if: proc { |attrs| attrs[:body].present? }
end