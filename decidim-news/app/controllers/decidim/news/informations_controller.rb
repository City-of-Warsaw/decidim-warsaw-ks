# frozen_string_literal: true

module Decidim
  module News
    # Controller that allows to view Information in public
    class InformationsController < Decidim::News::ApplicationController
      include Decidim::AdminExtended::HeroSectionHelper
      include Decidim::Paginable
      include Decidim::CoreExtended::CommentTokenCookie

      helper Decidim::FollowableHelper
      helper Decidim::AttachmentsHelper
      helper Decidim::SanitizeHelper

      layout 'layouts/decidim/hero_section_banner'

      helper_method :hero_section_public,
                    :info_or_request_title,
                    :banner_partial_name,
                    :pages_or_info_articles?,
                    :information,
                    :highlighted_cards,
                    :remaining_cards

      register_permissions(::Decidim::News::ApplicationController,
                           ::Decidim::News::Permissions,
                           ::Decidim::Permissions)

      def permission_class_chain
        ::Decidim.permissions_registry.chain_for(::Decidim::News::ApplicationController)
      end

      def index
        @collection = paginate(collection)
      end

      # admin can preview unpublished information in public view, from admin panel
      # when looking for id information, then consider the entire collection
      def show
        enforce_permission_to :show, :information, information:
      end

      private

      def information
        @information ||= entire_collection.find(params[:id])
      end

      def collection
        @collection ||= entire_collection.published.sorted_by_weight
      end

      def highlighted_cards
        @highlighted_cards ||= collection.first(3)
      end

      def remaining_cards
        @remaining_cards ||= collection.drop(3)
      end

      # admin can preview unpublished information in public view, from admin panel
      # when looking for id information, then consider the entire collection
      def entire_collection
        @entire_collection ||= Decidim::News::Information.where(decidim_organization_id: current_organization.id)
      end
    end
  end
end
