# frozen_string_literal: true

module Decidim
  module CoreExtended
    # A dummy presenter to abstract out the ad author.
    class AdAuthorPresenter < Decidim::OfficialAuthorPresenter
      def initialize(params = {})
        @model = params[:cell]
      end

      def name
        if @model.respond_to?(:signature) && @model.signature.present?
          @model.signature
        elsif @model.author.editorial.present?
          @model.author.editorial
        else
          I18n.t('.decidim.author.ad_user')
        end
      end

      def blocked?
        false
      end
    end
  end
end
