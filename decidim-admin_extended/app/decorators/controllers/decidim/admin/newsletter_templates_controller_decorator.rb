# frozen_string_literal: true

Decidim::Admin::NewsletterTemplatesController.class_eval do
  private

  # overwritten method
  # output only 2 desired by customer
  def templates
    @templates ||= Decidim.content_blocks.for(:newsletter_template).select { |b| allowed_templates.include?(b.name) }
  end

  def allowed_templates
    [:basic_only_text, :ks_multi_process]
  end
end
