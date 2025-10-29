# frozen_string_literal: true

require "cell/partial"

module Decidim
  module NewsletterTemplates
    class KsMultiProcessCell < Decidim::NewsletterTemplates::BaseCell
      include Decidim::NewsletterTemplates::SharedTemplateMethods

      def show
        render :show
      end

    end
  end
end
