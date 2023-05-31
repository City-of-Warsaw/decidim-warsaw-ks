# frozen_string_literal: true

Decidim::ContentBlocks::HeroCell.class_eval do

  def show
    render :show_new
  end

  def consultation_decor
    render :consultation_decor
  end

  def highlited
    options[:highlited]
  end

  private

  def text_from_button
    translated_attribute(current_organization.cta_button_text).presence || addition_to_welcome_text
  end

  def addition_to_welcome_text
    translated_attribute(model.settings.addition_to_welcome_text)
  end

  def hero_image_alt
    model.settings.hero_image_alt
  end
end
