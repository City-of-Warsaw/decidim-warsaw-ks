# frozen_string_literal: true

module Decidim
  module Remarks
    #
    # A dummy presenter to abstract out the unregistered author.
    #
    class RemarkPresenter < SimpleDelegator
      def initialize(params = {})
        @body = params[:body]
        @signature = params[:signature]
      end
    end
  end
end
