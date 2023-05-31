# frozen_string_literal: true

module Decidim
  module News
    module Admin
      # Controller that allows managing all the attachments for a participatory
      # process.
      #
      class AttachmentsController < Admin::ApplicationController
        include Decidim::Admin::Concerns::HasAttachments

        def after_destroy_path
          informations_path
        end

        def attached_to
          information
        end

        def information
          @information ||= informations.find(params[:information_id])
        end
      end
    end
  end
end
