# frozen_string_literal: true

require_dependency "decidim/custom_proposals/application_controller"

module Decidim::CustomProposals
  class CustomProposalsController < ApplicationController
    include Decidim::CoreExtended::CommentTokenCookie

    helper_method :custom_proposals,
                  :custom_proposal,
                  :first_published_followable_custom_proposal


    def index; end

    def show
      raise ActionController::RoutingError, "Not Found" unless custom_proposal

      custom_proposal
    end

    private

    def custom_proposals
      @custom_proposals ||= Decidim::CustomProposals::CustomProposal.published
                                                                    .where(component: current_component)
                                                                    .sorted_by_weight
    end

    def custom_proposal
      @custom_proposal ||= custom_proposals.find params[:id]
    end

    # Returns the first published custom_proposal in the database.
    # AD User should always published custom proposals component with at least 1 published custom proposal
    # therefore, there will be custom proposal available for users to follow.
    def first_published_followable_custom_proposal
      @first_published_followable_custom_proposal ||= custom_proposals.first
    end
  end
end
