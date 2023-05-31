# frozen_string_literal: true

Decidim::Admin::CreateArea.class_eval do
  private

  def create_area
    Decidim.traceability.create!(
      Decidim::Area,
      form.current_user,
      name: form.name,
      organization: form.organization,
      area_type: form.area_type,
      # custom
      color: form.color,
      text_color: form.text_color,
      # icon: form.icon
    )
  end
end
