# frozen_string_literal: true

module Decidim
  module AdminExtended
    class ApplicationController < Decidim::Admin::ApplicationController
      protect_from_forgery with: :exception
    end
  end
end
