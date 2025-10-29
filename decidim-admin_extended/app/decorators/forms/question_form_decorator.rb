# frozen_string_literal: true

Decidim::Forms::Admin::QuestionForm.class_eval do
  attribute :file_id, Integer
  attribute :gallery_id, Integer
  attribute :random_order, Decidim::AttributeObject::TypeMap::Boolean, default: false
end