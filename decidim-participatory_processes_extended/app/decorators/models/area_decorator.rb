# frozen_string_literal: true

# Class Decorator - Extending Decidim::Area
#
# Decorator implements additional functionalities to the model
# and changes existing methods.
Decidim::Area.class_eval do
  mount_uploader :icon, Decidim::IconUploader
end
