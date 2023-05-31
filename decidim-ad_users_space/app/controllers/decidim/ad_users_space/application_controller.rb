# frozen_string_literal: true

module Decidim
  module AdUsersSpace
    # This controller is the abstract class from which all other controllers of
    # this engine inherit.
    class ApplicationController < Decidim::ApplicationController
      before_action :enforce_permission

      private

      def enforce_permission
        enforce_permission_to :read, :ad_space
      end
    end
  end
end
