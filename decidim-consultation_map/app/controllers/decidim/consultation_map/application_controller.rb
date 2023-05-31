# frozen_string_literal: true

module Decidim
  module ConsultationMap
    # This controller is the abstract class from which all other controllers of
    # this engine inherit.
    #
    # Note that it inherits from `Decidim::Components::BaseController`, which
    # override its layout and provide all kinds of useful methods.
    class ApplicationController < Decidim::Components::BaseController
      helper Decidim::ConsultationMap::ApplicationHelper
    end
  end
end
