# frozen_string_literal: true

require_dependency 'file_form_validator'

module Decidim
  module GeneralPlanRequests
    class GeneralPlanRequest < ApplicationRecord
      include Decidim::HasComponent
      include Decidim::Loggable
      include Decidim::Participable # for routing
      include Decidim::ParticipatorySpaceResourceable # for routing
      include Decidim::GeneralPlanRequests::GeneralPlanRequestHelper

      before_create :generate_uuid

      # 0 - 2.1 wniosek do projektu aktu
      # 1 - 2.2 uwaga do konsultowanego projektu aktu
      # 2 - 2.3 wniosek o zmianę aktu
      # 3 - 2.4 wniosek o sporządenie aktu
      enum letter_type: {
        project_act_request: 0,
        consulted_act_project_remark: 1,
        request_to_amend_act: 2,
        request_to_prepare_act: 3
      }

      # 0 - 3.1 plan ogólny gminy
      # 1 - 3.2 miejscowy plan zagospodarowania przestrzennego, tym zintegrowany plan inwestycyjny
      #         lub miejscowy plan rewitalizacji
      # 2 - 3.3 uchwała ustalająca zasady i warunki sytuowania obiektów małej architektury,
      #         tablic reklamowych i urządzeń reklamowych oraz ogrodzeń,
      #         ich gabaryty, standardy jakościowe oraz rodzaje materiałów budowlanych, z jakich mogą być wykonane
      # 3 - 3.4 audyt krajobrazowy
      # 4 - 3.5 plan zagospodarowania przestrzennego województwa
      enum urban_planning_act_type: {
        community_general_plan: 0,
        local_development_or_revitalisation_plan: 1,
        resolution_establishing_rules: 2,
        landscape_audit: 3,
        voivodship_development_plan: 4
      }

      # submitter data role
      INDIVIDUAL = 0
      ORGANIZATION = 1

      # attorney data role
      ATTORNEY = 0
      ATTORNEY_FOR_SERVICE = 1

      has_one_attached :attorney_power_represent_applicant_or_for_service
      has_one_attached :attorney_power_payment_stamp_duty_confirm
      has_one_attached :parcel_site_boundary

      has_many_attached :files

      validates :attorney_power_represent_applicant_or_for_service, file_form: {
        max_size: 5.megabytes,
        acceptable_types: %w[
          image/jpg
          image/jpeg
          application/pdf
        ]
      }

      validates :attorney_power_payment_stamp_duty_confirm, file_form: {
        max_size: 5.megabytes,
        acceptable_types: %w[
          image/jpg
          image/jpeg
          application/pdf
        ]
      }

      validates :parcel_site_boundary, file_form: {
        max_size: 5.megabytes,
        acceptable_types: %w[
          image/jpg
          image/jpeg
          application/pdf
        ]
      }

      validates :files, file_form: {
        count: 2,
        max_size: 5.megabytes,
        acceptable_types:
          %w[
            image/jpg
            image/jpeg
            application/pdf
            application/msword
            application/vnd.openxmlformats-officedocument.wordprocessingml.document
            application/vnd.oasis.opendocument.text
            text/rtf
            application/vnd.ms-excel
            application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
            application/vnd.ms-powerpoint
            application/vnd.openxmlformats-officedocument.presentationml.presentation
          ]
      }

      # Presenter class for AdminLogs
      def self.log_presenter_class_for(_log)
        Decidim::GeneralPlanRequests::AdminLog::GeneralPlanRequestPresenter
      end

      def pdf_name
        date = I18n.l(created_at, format: "%d/%m/%Y")
        "#{id}_#{date}_potwierdzenie"
      end

      def generate_uuid
        self.uuid = SecureRandom.hex(16)
      end

      def anonymized_pdf_name
        "#{pdf_name}-zanonimizowany"
      end

      def pdf_template
        'decidim/general_plan_requests/shared/show'
      end

      def registered_to_signum?
        signum_nr_kancelaryjny.present?
      end
    end
  end
end
