# frozen_string_literal: true

Decidim::HasSettings.module_eval do
  # custom_settings setting attr is used only by:
  # - study notes component
  # - consultation map component
  def custom_settings
    new_settings_schema(:custom, self[:settings]["custom"])
  end

  # custom_settings setting attr is used only by:
  # - study notes component
  # - consultation map component
  def custom_settings=(data)
    self[:settings]["custom"] = new_settings_schema(:custom, data)
  end

  # admin_email setting attr is used only by:
  # - study notes component
  # - general plan request component
  def admin_email
    self[:settings]["admin_email"]
  end

  # admin_email setting attr is used only by:
  # - study notes component
  # - general plan request component
  def admin_email=(value)
    self[:settings]["admin_email"] = value
  end

  # description setting attr is used only by:
  # study notes component
  def description
    self[:settings]["description"]
  end

  # description setting attr is used only by:
  # study notes component
  def description=(value)
    self[:settings]["description"] = value
  end
end
