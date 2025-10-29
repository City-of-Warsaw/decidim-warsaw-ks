# frozen_string_literal: true

module Decidim
  module News
    # The News application controller that inherits from The main application controller.
    class ApplicationController < Decidim::ApplicationController
      protect_from_forgery with: :exception
    end
  end
end
