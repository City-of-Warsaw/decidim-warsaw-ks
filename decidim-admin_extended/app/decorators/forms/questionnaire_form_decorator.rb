# frozen_string_literal: true

Decidim::Forms::Admin::QuestionnaireForm.class_eval do
  attribute :file_id, Integer
  attribute :gallery_id, Integer
end