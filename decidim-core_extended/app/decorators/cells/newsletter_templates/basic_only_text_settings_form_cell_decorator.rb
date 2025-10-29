# frozen_string_literal: true

Decidim::NewsletterTemplates::BasicOnlyTextSettingsFormCell.class_eval do
    def show
      render :show_new
    end
end
