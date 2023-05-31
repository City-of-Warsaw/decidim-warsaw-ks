# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessesExtended
    class ApplicationController < Decidim::ApplicationController
      protect_from_forgery with: :exception
    end
  end
end
