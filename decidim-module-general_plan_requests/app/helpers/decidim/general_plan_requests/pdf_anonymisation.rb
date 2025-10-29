# frozen_string_literal: true

module Decidim
  module GeneralPlanRequests
    module PdfAnonymisation
      private

      def anonymize_general_plan_request(gpr)
        # do not anonymize organisation data
        if gpr.submitter_data_role == Decidim::GeneralPlanRequests::GeneralPlanRequest::INDIVIDUAL
          anonymize_submitter_data(gpr)
        end

        # all mailing address data can be blank or all mailing data must be filled in the form
        if gpr.mailing_address_data_country.present?
          anonymize_mailing_address_data(gpr)
        end

        # all attorney data can be blank or all attorney data must be filled in the form
        if gpr.attorney_data_first_name.present?
          anonymize_attorney_data(gpr)
        end
      end

      def anonymize_submitter_data(gpr)
        gpr.submitter_data_first_name = '*********'
        gpr.submitter_data_last_name = '*********'
        gpr.submitter_data_org_name = '*********'
        gpr.submitter_data_country = '*********'
        gpr.submitter_data_voivodeship = '*********'
        gpr.submitter_data_county = '*********'
        gpr.submitter_data_community = '*********'
        gpr.submitter_data_street = '*********'
        gpr.submitter_data_street_number = '***'
        gpr.submitter_data_flat_number = '***'
        gpr.submitter_data_city = '*********'
        gpr.submitter_data_zip_code = '******'
        gpr.submitter_data_phone_number = '*********'
        gpr.submitter_data_email = '*********'
        gpr.submitter_data_epuap_delivery_address = '*********'
      end

      def anonymize_mailing_address_data(gpr)
        gpr.mailing_address_data_country = '*********'
        gpr.mailing_address_data_voivodeship = '*********'
        gpr.mailing_address_data_county = '*********'
        gpr.mailing_address_data_community = '*********'
        gpr.mailing_address_data_street = '*********'
        gpr.mailing_address_data_street_number = '***'
        gpr.mailing_address_data_flat_number = '***'
        gpr.mailing_address_data_city = '*********'
        gpr.mailing_address_data_zip_code = '******'
      end

      def anonymize_attorney_data(gpr)
        gpr.attorney_data_first_name = '*********'
        gpr.attorney_data_last_name = '*********'
        gpr.attorney_data_country = '*********'
        gpr.attorney_data_voivodeship = '*********'
        gpr.attorney_data_county = '*********'
        gpr.attorney_data_community = '*********'
        gpr.attorney_data_street = '*********'
        gpr.attorney_data_street_number = '***'
        gpr.attorney_data_flat_number = '***'
        gpr.attorney_data_city = '*********'
        gpr.attorney_data_zip_code = '******'
        gpr.attorney_data_phone_number = '*********'
        gpr.attorney_data_email = '*********'
        gpr.attorney_data_epuap_delivery_address = '*********'
      end
    end
  end
end
