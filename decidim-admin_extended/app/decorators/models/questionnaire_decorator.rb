# frozen_string_literal: true

Decidim::Forms::Questionnaire.class_eval do
  belongs_to :file, class_name: "Decidim::Repository::File", optional: true
  belongs_to :gallery, class_name: "Decidim::Repository::Gallery", optional: true
end