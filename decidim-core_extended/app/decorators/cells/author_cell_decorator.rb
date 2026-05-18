# frozen_string_literal: true

Decidim::AuthorCell.class_eval do
  # overwritten method
  # kill caching
  # TODO: PO UKOŃCZONYCH TESTACH KLIENTA V29 rollback - cofnąć to nadpisanie
  def perform_caching?
    false
  end

  # overwritten
  # for AD user with editorial or signature - that should be displayed in comments
  # tip: comments in process and search are display by different cells
  def author_name
    return options[:author_name_text] if options[:author_name_text].present?

    if model.respond_to?(:signature) && model.signature.present?
      model.signature
    elsif model.respond_to?(:editorial) && model.editorial.present?
      model.editorial
    else
      model.name
    end
  end

  # overwritten method
  # disable profile preview
  def profile_path?
    false
  end

  def search_controller?
    controller.class.name == "Decidim::SearchesController"
  end

  def remarks_controller?
    controller.class.name == "Decidim::Remarks::RemarksController"
  end

  def map_remarks_controller?
    controller.class.name == "Decidim::ConsultationMap::RemarksController"
  end

  def user_questions_controller?
    controller.class.name == "Decidim::ExpertQuestions::UserQuestionsController"
  end

  # overwritten method
  # make it nil
  # TODO: PO UKOŃCZONYCH TESTACH KLIENTA V29 rollback - cofnąć to nadpisanie
  def cache_hash
    nil
  end
end
