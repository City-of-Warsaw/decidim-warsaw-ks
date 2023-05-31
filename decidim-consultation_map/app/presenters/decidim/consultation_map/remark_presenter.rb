# frozen_string_literal: true

module Decidim
  module ConsultationMap
    #
    # A dummy presenter to abstract out the unregistered author.
    #
    class RemarkPresenter < SimpleDelegator
      def initialize(params = {})
        @body = params[:body]
        @signature = params[:signature]
        @latitude = params[:latitude]
        @longitude = params[:longitude]
      end
    end
  end
end
