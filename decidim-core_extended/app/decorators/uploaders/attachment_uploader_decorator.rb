# frozen_string_literal: true

Decidim::AttachmentUploader.class_eval do

  # for participatory_process gallery
  version :thumbnail_gal, if: :image? do
    process resize_to_fit: [nil, 237] # original
    # process resize_to_fit: [237, nil]
    # process resize_and_pad: [237, 152] # sotawia ramke do okola, jest ok
    # process resize_to_fill: [nil, 152] #
  end

  # This override and remove attachment size validation
  def validate_dimensions
  end
end