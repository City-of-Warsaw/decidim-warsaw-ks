# frozen_string_literal: true

Decidim::NewsletterTemplates::BasicOnlyTextCell.class_eval do
  include Decidim::NewsletterTemplates::SharedTemplateMethods

  def show
    render :show_new
  end

end
