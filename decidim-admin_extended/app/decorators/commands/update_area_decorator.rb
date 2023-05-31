# frozen_string_literal: true

Decidim::Admin::UpdateArea.class_eval do
  private

  def attributes
    {
      name: form.name,
      area_type: form.area_type,
      # custom
      color: form.color,
      text_color: form.text_color,
      # icon: form.icon
    }
  end
end
