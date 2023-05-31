# frozen_string_literal: true

# OVERWRITTEN DECIDIM FORM
# A form object used to create and update static page from admin panel
# Class has been provided with attributes for adding parent and visibility of object
# Form has been expanded with attributes:
# - gallery_id - for adding gallery from the Repository
# - show_on_help_page - For handling visibility in help page section
Decidim::Admin::StaticPageForm.class_eval do
  attribute :gallery_id, Integer
  attribute :show_on_help_page, GraphQL::Types::Boolean
end
