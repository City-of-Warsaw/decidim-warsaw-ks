# frozen_string_literal: true

module Decidim
  module CoreExtended
    # A dummy presenter to abstract out the unregistered author.
    class UnregisteredAuthorPresenter < Decidim::OfficialAuthorPresenter
      def initialize(params = {})
        @model = params[:cell]
      end

      # overwritten method
      # change name content
      def name
        return @model.signature if @model&.signature.present?

        # For the case where the model (user) is nil or signature is not present
        I18n.t("decidim.author.signature_missing") unless @model&.author
      end

      def blocked?
        false
      end

      # overwritten method
      # change param
      def avatar_url(_size = nil)
        ActionController::Base.helpers.asset_pack_path("media/images/default-avatar.svg")
      end

      # overwritten method
      # make it nil
      def profile_path
        nil
      end
    end
  end
end
