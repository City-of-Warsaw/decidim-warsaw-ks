# frozen_string_literal: true

require "decidim/custom_proposals/admin"
require "decidim/custom_proposals/engine"
require "decidim/custom_proposals/admin_engine"
require "decidim/custom_proposals/component"

module Decidim
  # This namespace holds the logic of the `CustomProposals` component. This component
  # allows users to create custom_proposals in a participatory space.
  module CustomProposals
    autoload :CustomProposalCommentsSerializer, "decidim/custom_proposals/custom_proposal_comments_serializer"
  end
end
