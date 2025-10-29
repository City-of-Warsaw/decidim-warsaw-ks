# frozen_string_literal: true

Decidim::Forms::Question.class_eval do
  belongs_to :file, class_name: "Decidim::Repository::File", optional: true
  belongs_to :gallery, class_name: "Decidim::Repository::Gallery", optional: true

  def single_option?
    %w(single_option matrix_single).include?(question_type)
  end
end