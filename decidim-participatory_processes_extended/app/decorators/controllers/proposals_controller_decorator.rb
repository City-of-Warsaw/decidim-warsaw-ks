# frozen_string_literal: true

Decidim::Proposals::ProposalsController.class_eval do
  # overwrite: added private method
  # to render help_section in processes components proposals view

  helper_method :proposals_help_section

  # redirect from show to index with unhide comments
  def show
    raise ActionController::RoutingError, "Not Found" if @proposal.blank? || !can_show_proposal?

    redirect_to action: :index, proposal_id: @proposal.id
  end

  private

  def proposals_help_section
    current_component.settings[:help_section]
  end
end
