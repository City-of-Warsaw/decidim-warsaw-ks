# frozen_string_literal: true

module Decidim
  module Remarks
    # Custom helpers, scoped to the remarks engine.
    #
    module ApplicationHelper
      include PaginateHelper
      include Decidim::Comments::CommentsHelper
      include ::Decidim::FollowableHelper
    end
  end
end
