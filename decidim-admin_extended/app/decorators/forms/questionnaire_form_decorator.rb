# frozen_string_literal: true

Decidim::Forms::Admin::QuestionnaireForm.class_eval do
  include Decidim::Repository::Admin::GalleryInputAttributes
  include Decidim::Repository::Admin::GalleriesValidations

  attribute :file_id, Integer

  # new: setup gallery_id
  def map_model(model)
    self.questions = model.questions.map do |question|
      Decidim::Forms::Admin::QuestionForm.from_model(question)
    end
    self.gallery_id = model.gallery_id
  end
end
