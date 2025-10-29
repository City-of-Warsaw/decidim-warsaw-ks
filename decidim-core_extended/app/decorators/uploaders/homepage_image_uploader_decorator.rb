# frozen_string_literal: true

Decidim::HomepageImageUploader.class_eval do
  # overwritten: change bix size for image
  set_variants do
    { big: { resize_to_fill: [1900, 1400] } }
  end
end