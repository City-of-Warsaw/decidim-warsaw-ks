# frozen_string_literal: true

Decidim::ContentBlocks::ParticipatorySpaceDocumentsCell.class_eval do
  # Overwritten for not show attachment from meetings in proces page
  # 
  def components_collections
    []
  end
end
