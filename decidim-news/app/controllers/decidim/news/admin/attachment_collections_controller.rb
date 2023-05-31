# frozen_string_literal: true

module Decidim
  module News
    module Admin
      # Controller that allows managing all the attachment collections for an assembly.
      #
      class AttachmentCollectionsController < Admin::ApplicationController
        include Decidim::Admin::Concerns::HasAttachmentCollections

        def after_destroy_path
          admin_information_attachment_collections_path(information, current_participatory_space)
        end

        def collection_for
          information
        end

        def information
          @information ||= informations.find(params[:information_id])
        end
      end
    end
  end
end
