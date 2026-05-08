# frozen_string_literal: true
Decidim::System::BaseOrganizationForm.class_eval do
      # Add second set of attributes for smtp settings
      attribute :from_email_n, String
      attribute :from_label_n, String
      attribute :user_name_n, String
      attribute :password_n, String
      attribute :address_n, String
      attribute :port_n, String
end
