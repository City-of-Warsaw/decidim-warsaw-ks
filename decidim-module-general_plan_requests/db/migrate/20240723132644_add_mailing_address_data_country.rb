class AddMailingAddressDataCountry < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_general_plan_requests_general_plan_requests,
               :mailing_address_data_country,
               :string
  end
end
