# frozen_string_literal: true

Decidim::ParticipatoryProcesses::ContentBlocks::MetadataCell.class_eval do
  def show
    render :content_new
  end
end
