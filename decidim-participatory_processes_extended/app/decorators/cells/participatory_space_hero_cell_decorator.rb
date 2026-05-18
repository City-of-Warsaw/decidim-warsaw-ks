# frozen_string_literal: true

Decidim::ContentBlocks::ParticipatorySpaceHeroCell.class_eval do
  # overwritten method - view
  # move old process header view v24
  # into this new process hero block
  def show
    render :show_new
  end

  # overwritten method
  # changed way to display imgs
  # add hero img for show process - into this content block
  # add image alt - into this content block
  # legend:
  # background_image - decidim process hero - comes from content block process hero settings
  # hero_image - decidim process attached img - comes from process form
  def image_path
    container = model.respond_to?(:images_container) ? model.images_container : nil

    if container&.attached_uploader(:background_image)&.attached?
      return image_tag(model.images_container.attached_uploader(:background_image).url,
                       alt: image_alt.presence || translated_attribute(current_participatory_space.title),
                       class: "process-main-image")
    end

    if (hero_image = current_participatory_space.hero_image)&.attached?
      return image_tag(Rails.application.routes.url_helpers.rails_representation_path(
                         hero_image.variant(resize: "5000x>").processed, only_path: true
                       ), alt: current_participatory_space.hero_image_alt.presence || translated_attribute(current_participatory_space.title),
                          class: "process-main-image")
    end

    nil
  end

  private

  def image_alt
    return unless model

    @image_alt ||= model.settings.image_alt.presence
  end
end
