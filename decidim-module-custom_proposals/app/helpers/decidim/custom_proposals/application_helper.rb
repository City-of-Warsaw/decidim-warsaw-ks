# frozen_string_literal: true

module Decidim
  module CustomProposals
    # Custom helpers, scoped to the custom_proposals engine
    module ApplicationHelper
      include Decidim::Comments::CommentsHelper
      include ::Decidim::FollowableHelper
    end
  end
end
