# frozen_string_literal: true

require "decidim/translatable_attributes"

# OVERWRITTEN DECIDIM FORM
# A form object used to update organizations from the system dashboard.
# Class was provided with attributes for adding second set of smtp settings to Organization
Decidim::System::UpdateOrganizationForm.class_eval do

  # second set of attributes for smtp settings
  jsonb_attribute :newsletter_smtp_settings, [
    [:from_n, String],
    [:from_email_n, String],
    [:from_label_n, String],
    [:user_name_n, String],
    [:encrypted_password_n, String],
    [:address_n, String],
    [:port_n, Integer],
    [:authentication_n, String],
    [:enable_starttls_auto_n, GraphQL::Types::Boolean]
  ]

  attr_writer :password_n

  # method that allows encrypt password from database
  def password_n
    Decidim::AttributeEncryptor.decrypt(encrypted_password_n) unless encrypted_password_n.nil?
  end

  # OVERWRITTEN DECIDIM METHOD
  # added mapping for second set of attributes for smtp settings
  def map_model(model)
    super

    unless model.newsletter_smtp_settings.nil?
      self.port_n = model.newsletter_smtp_settings['port']
      self.address_n = model.newsletter_smtp_settings['address']
      self.user_name_n = model.newsletter_smtp_settings['user_name']
      self.from_email_n = model.newsletter_smtp_settings['from_email']
      self.from_label_n = model.newsletter_smtp_settings['from_label']
      self.encrypted_password_n = model.newsletter_smtp_settings['encrypted_password']
      # self.password_n = password_n
    end
  end

  # method preparing data from attributes to be saved in Organization object
  # returns Hash
  def encrypted_newsletter_smtp_settings
    new_smtp_settings = {}
    new_smtp_settings["from"] = set_from_n
    new_smtp_settings["port"] = port_n
    new_smtp_settings["address"] = address_n
    new_smtp_settings["user_name"] = user_name_n
    new_smtp_settings["from_email"] = from_email_n
    new_smtp_settings["from_label"] = from_label_n
    new_smtp_settings["encrypted_password"] = Decidim::AttributeEncryptor.encrypt(@password_n)

    new_smtp_settings
  end

  # method preparing data saved to serve as mail signature
  def set_from_n
    return from_email_n if from_label_n.blank?

    "#{from_label_n} <#{from_email_n}>"
  end
end