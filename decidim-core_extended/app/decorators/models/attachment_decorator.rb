# frozen_string_literal: true
Decidim::Attachment.class_eval do
  # Fixed form newer version decidim -> https://github.com/decidim/decidim/compare/develop...PopulateTools:decidim:fix/allow_deleting_link_attachments

    skip_callback(:before_validation)
    before_validation :set_link_content_type_and_size, if: :editable_link?

    # Whether this attachment is a link that can be edited or not.
    #
    # Returns Boolean.
    def editable_link?
      !destroyed? && !frozen? && link?
    end
end
