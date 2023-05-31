# frozen_string_literal: true

# Class Decorator - Extending Decidim::HasSettings
#
# Class has been expanded with:
# additional methods for additional attributes
Decidim::HasSettings.module_eval do
  def custom_settings
    new_settings_schema(:custom, self[:settings]["custom"])
  end

  def custom_settings=(data)
    self[:settings]["custom"] = new_settings_schema(:custom, data)
  end

  # admin_email only for Study Notes component
  def admin_email
    self[:settings]["admin_email"]
  end

  def admin_email=(value)
    self[:settings]["admin_email"] = value
  end

  # description only for Study Notes component
  def description
    self[:settings]["description"]
  end

  def description=(value)
    self[:settings]["description"] = value
  end
end
