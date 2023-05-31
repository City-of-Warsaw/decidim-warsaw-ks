# frozen_string_literal: true

# require "cell/partial"
# require "cells/decidim/card_m_cell"

Decidim::Proposals::ParticipatoryTextProposalCell.class_eval do
  include Decidim::Comments::CommentsHelper

  def show
    render :show_new
  end

  def participatory_space
    render :participatory_space
  end

  def title
    "<h3 class='collapsable-header' tabindex='0' data-toggle='#{node_id}'>#{section_title}</h3>"
  end

  def node_id
    "proposal-#{model.id}"
  end

  def show_comments
    cell(
      "decidim/proposals/comments",
      model,
      machine_translations: false,
      single_comment: params.fetch("commentId", nil),
      order: "recent"
    ).to_s
  end
end