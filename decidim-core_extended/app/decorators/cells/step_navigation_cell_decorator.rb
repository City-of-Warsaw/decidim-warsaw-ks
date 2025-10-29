# frozen_string_literal: true

Decidim::Forms::StepNavigationCell.class_eval do
  def show
    render :show_new
  end    

  def previous_step_dom_id
    if current_step_index == 1
      "step-#{current_step_index - 1} survey-help survey-info"
    else
      "step-#{current_step_index - 1}"
    end
  end
end