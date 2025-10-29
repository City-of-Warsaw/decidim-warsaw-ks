# frozen_string_literal: true

Decidim::ContentBlocks::ParticipatorySpaceMainDataCell.class_eval do
  # overwritten method-view
  # it comes from
  # Decidim::ContentBlocks::BaseCell - ParticipatorySpaceMainDataCell inherits from it
  # overwrite it only to overwrite its content - it is CRUCIAL to KEEP UNCHANGED:
  # - "participatory-space__content-block" section class in show view
  # for content_new:
  # take out the follow button and timeline from nav items and put in the content_new of this cell
  def show
    render :show_new
  end
end
