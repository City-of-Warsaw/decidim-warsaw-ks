# frozen_string_literal: true

module Decidim
  module CoreExtended
    module GenerateTokenHelper
      include Decidim::CoreExtended::AuthorParamsBuilder

      attr_accessor :author

      def generate_token
        author == unregistered_author ? SecureRandom.hex(rand(59)) : nil
      end
    end
  end
end
