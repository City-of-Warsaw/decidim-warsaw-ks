# frozen_string_literal: true

require "decidim/custom_ai/admin"
require "decidim/custom_ai/engine"
require "decidim/custom_ai/admin_engine"

module Decidim
  # This namespace holds the logic of the `CustomAi` component. This component
  # allows users to create custom_ai in a participatory space.
  module CustomAi
    autoload :AnswersSerializer, "decidim/custom_ai/answers_serializer"
  end
end
