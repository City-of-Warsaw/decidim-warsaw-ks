class CreateDecidimGeneralPlanRequestsGeneralPlanRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_general_plan_requests_general_plan_requests do |t|
      t.references :decidim_component,
                   foreign_key: true,
                   index: { name: 'index_dec_general_plan_requests_on_dec_component_id' }

      # attrs for sections 1, 2, 3
      t.string :authority_name_which_letter_is_addressed, default: 'Prezydent m.st. Warszawy'
      t.integer :letter_type, default: 0
      t.integer :urban_planning_act_type, default: 0

      # attrs for section 4 - submitter data
      t.integer :submitter_data_role
      t.string :submitter_data_first_name
      t.string :submitter_data_last_name
      t.string :submitter_data_org_name
      t.string :submitter_data_country
      t.string :submitter_data_voivodeship
      t.string :submitter_data_county
      t.string :submitter_data_community
      t.string :submitter_data_street
      t.string :submitter_data_street_number
      t.string :submitter_data_flat_number
      t.string :submitter_data_city
      t.string :submitter_data_zip_code
      t.string :submitter_data_email
      t.string :submitter_data_phone_number
      t.string :submitter_data_ePUAP_box_address_or_electronic_delivery_address
      t.string :perpetual_owner_of_the_property

      # attrs for section 5 - mailing address data
      t.string :mailing_address_data_voivodeship
      t.string :mailing_address_data_county
      t.string :mailing_address_data_community
      t.string :mailing_address_data_street
      t.string :mailing_address_data_street_number
      t.string :mailing_address_data_flat_number
      t.string :mailing_address_data_city
      t.string :mailing_address_data_zip_code

      # attrs for section 6 - attorney data
      t.integer :attorney_data_role
      t.string :attorney_data_first_name
      t.string :attorney_data_last_name
      t.string :attorney_data_country
      t.string :attorney_data_voivodeship
      t.string :attorney_data_county
      t.string :attorney_data_community
      t.string :attorney_data_street
      t.string :attorney_data_street_number
      t.string :attorney_data_flat_number
      t.string :attorney_data_city
      t.string :attorney_data_zip_code
      t.string :attorney_data_email
      t.string :attorney_data_phone_number
      t.string :attorney_data_ePUAP_box_address_or_electronic_delivery_address

      # attrs for section 7 - letter content
      t.string :request_body
      t.string :request_body_content_details
      t.string :details_land_parcels_with_parameters

      # attrs for section 8 - declaration remote correspondence
      t.boolean :declaration_remote_correspondence

      # attrs for section 9 - only for files: filenames. the rest is attached with active storage
      t.string :files_filename_one
      t.string :files_filename_two

      # attrs for additional section - optional email confirmation request
      t.boolean :optional_confirmation_request
      t.string :email_confirmation_request

      # last attrs
      t.boolean :confirm_read_process_description
      t.boolean :confirm_process_personal_data

      t.timestamps
    end
  end
end
