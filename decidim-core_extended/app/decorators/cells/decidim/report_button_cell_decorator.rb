# frozen_string_literal: true

Decidim::ReportButtonCell.class_eval do
  # overwritten method
  # swap view with ours to add reason: 'other'
  # swap view with ours to change labels
  def flag_modal
    return render :already_reported_modal if model.reported_by?(current_user)

    render :flag_modal_new
  end
end
