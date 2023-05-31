# frozen_string_literal: true

module Decidim
  module ConsultationRequests
    # This controller is the abstract class from which all other controllers of
    # this engine inherit.
    class ApplicationController < Decidim::ApplicationController
      protect_from_forgery with: :exception
    end
  end
end
