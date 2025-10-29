module Decidim
  module CoreExtended
    class ApplicationController < Decidim::ApplicationController
      protect_from_forgery with: :exception
    end
  end
end
