# frozen_string_literal: true

Decidim::AuthorCell.class_eval do

  def show
    render :show_new
  end

  # overwritten, remove link for blocked users
  def profile_path?
    return false if model.blocked?
    return false if options[:skip_profile_link] == true

    profile_path.present?
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
  # overwritten cell view
  def flag_user
    render :flag_user_new unless current_user == model
  end

  # overwritten method
  # overwritten cell view
  def flag
    render :flag_new
  end

  def has_actions?
    options[:has_actions] == true
  end

  def excluding_controller_action?
    index_action? && (!remarks_controller? || !map_remarks_controller || !user_questions_controller)
  end

  def flaggable?
    return unless from_context
    return unless context[:controller].try(:flaggable_controller?)
    return if excluding_controller_action?

    true
  end

  def render_flag
    if from_context.class.name == "Decidim::Remarks::Remark"
      cell("decidim/remarks/remark_m", from_context).(:flag_remark)
    elsif from_context.class.name == "Decidim::ConsultationMap::Remark"
      cell("decidim/consultation_map/remark_m", from_context).(:flag_remark)
    elsif from_context.class.name == "Decidim::ExpertQuestions::UserQuestion"
      cell("decidim/expert_questions/user_question_m", from_context).(:flag_question)
    end
  end

  private

  # overwritten method
  # due to overwritten cell view, removed one condition: show_action?
  def creation_date?
    return unless from_context
    return unless (from_context.respond_to?(:published_at) || from_context.respond_to?(:created_at))

    true
  end

  # overwritten method
  # change format date - removed hours & minutes
  def creation_date
    date_at = from_context.try(:published_at) || from_context.try(:created_at)

    l date_at, format: :decidim_short_no_time
  end

end
