# frozen_string_literal: true

Decidim::ImageUploader.class_eval do

  # Overrided for change error messages
  def validate_dimensions
    manipulate! do |image|
      validation_error!(I18n.t("carrierwave.errors.image_dimension_too_big", max: max_image_height_or_width)) if image.dimensions.any? { |dimension| dimension > max_image_height_or_width }
      image
    end
  end

  # Overrided for change error messages
  def validate_size
    manipulate! do |image|
      validation_error!(I18n.t("carrierwave.errors.image_size_too_big", max: maximum_upload_size)) if image.size > maximum_upload_size
      image
    end
  end
end