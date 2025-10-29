class CleanStudyNotesColumn < ActiveRecord::Migration[7.0]
  def change
    ActiveRecord::Base.connection.execute("TRUNCATE decidim_study_notes_study_notes")
    add_column :decidim_study_notes_study_notes, :authority_name_which_letter_is_addressed,:string, default: "Prezydent m.st. Warszawy"
add_column :decidim_study_notes_study_notes, :urban_planning_act_type,:integer, default: 0
add_column :decidim_study_notes_study_notes, :submitter_data_role,:string
add_column :decidim_study_notes_study_notes, :submitter_data_first_name,:string
add_column :decidim_study_notes_study_notes, :submitter_data_last_name,:string
add_column :decidim_study_notes_study_notes, :submitter_data_org_name,:string
add_column :decidim_study_notes_study_notes, :submitter_data_country,:string
add_column :decidim_study_notes_study_notes, :submitter_data_voivodeship,:string
add_column :decidim_study_notes_study_notes, :submitter_data_county,:string
add_column :decidim_study_notes_study_notes, :submitter_data_community,:string
add_column :decidim_study_notes_study_notes, :submitter_data_street,:string
add_column :decidim_study_notes_study_notes, :submitter_data_street_number,:string
add_column :decidim_study_notes_study_notes, :submitter_data_flat_number,:string
add_column :decidim_study_notes_study_notes, :submitter_data_city,:string
add_column :decidim_study_notes_study_notes, :submitter_data_zip_code,:string
add_column :decidim_study_notes_study_notes, :submitter_data_email,:string
add_column :decidim_study_notes_study_notes, :submitter_data_phone_number,:string
add_column :decidim_study_notes_study_notes, :submitter_data_epuap_delivery_address,:string
add_column :decidim_study_notes_study_notes, :mailing_address_data_voivodeship,:string
add_column :decidim_study_notes_study_notes, :mailing_address_data_county,:string
add_column :decidim_study_notes_study_notes, :mailing_address_data_community,:string
add_column :decidim_study_notes_study_notes, :mailing_address_data_street,:string
add_column :decidim_study_notes_study_notes, :mailing_address_data_street_number,:string
add_column :decidim_study_notes_study_notes, :mailing_address_data_flat_number,:string
add_column :decidim_study_notes_study_notes, :mailing_address_data_city,:string
add_column :decidim_study_notes_study_notes, :mailing_address_data_zip_code,:string
add_column :decidim_study_notes_study_notes, :attorney_data_role, :integer
add_column :decidim_study_notes_study_notes, :attorney_data_first_name,:string
add_column :decidim_study_notes_study_notes, :attorney_data_last_name,:string
add_column :decidim_study_notes_study_notes, :attorney_data_country,:string
add_column :decidim_study_notes_study_notes, :attorney_data_voivodeship,:string
add_column :decidim_study_notes_study_notes, :attorney_data_county,:string
add_column :decidim_study_notes_study_notes, :attorney_data_community,:string
add_column :decidim_study_notes_study_notes, :attorney_data_street,:string
add_column :decidim_study_notes_study_notes, :attorney_data_street_number,:string
add_column :decidim_study_notes_study_notes, :attorney_data_flat_number,:string
add_column :decidim_study_notes_study_notes, :attorney_data_city,:string
add_column :decidim_study_notes_study_notes, :attorney_data_zip_code,:string
add_column :decidim_study_notes_study_notes, :attorney_data_email,:string
add_column :decidim_study_notes_study_notes, :attorney_data_phone_number,:string
add_column :decidim_study_notes_study_notes, :attorney_data_epuap_delivery_address,:string
add_column :decidim_study_notes_study_notes, :request_body,:text
add_column :decidim_study_notes_study_notes, :request_body_content_details,:jsonb
add_column :decidim_study_notes_study_notes, :details_land_parcels_with_parameters,:jsonb
add_column :decidim_study_notes_study_notes, :declaration_remote_correspondence,:boolean
add_column :decidim_study_notes_study_notes, :files_filename_one, :string
add_column :decidim_study_notes_study_notes, :files_filename_two,:string
add_column :decidim_study_notes_study_notes, :optional_confirmation_request,:boolean
add_column :decidim_study_notes_study_notes, :email_confirmation_request,:string
add_column :decidim_study_notes_study_notes, :confirm_read_process_description,:boolean
add_column :decidim_study_notes_study_notes, :confirm_process_personal_data,:boolean
add_column :decidim_study_notes_study_notes, :mailing_address_data_country,:string
add_column :decidim_study_notes_study_notes, :uuid,:string
add_column :decidim_study_notes_study_notes, :perpetual_owner_of_the_property,:boolean
    add_column :decidim_study_notes_study_notes, :letter_type,:integer

    # remove_column OLD COMPONENT
    remove_column :decidim_study_notes_study_notes, :category_id
    remove_column :decidim_study_notes_study_notes, :organization_name
    remove_column :decidim_study_notes_study_notes, :first_name
    remove_column :decidim_study_notes_study_notes, :last_name
    remove_column :decidim_study_notes_study_notes, :email
    remove_column :decidim_study_notes_study_notes, :body
    remove_column :decidim_study_notes_study_notes, :locations
    remove_column :decidim_study_notes_study_notes, :location_specification
    remove_column :decidim_study_notes_study_notes, :map_background_id
    remove_column :decidim_study_notes_study_notes, :street
    remove_column :decidim_study_notes_study_notes, :street_number
    remove_column :decidim_study_notes_study_notes, :flat_number
    remove_column :decidim_study_notes_study_notes, :zip_code
    remove_column :decidim_study_notes_study_notes, :city
    remove_column :decidim_study_notes_study_notes, :token
  end
end
