# frozen_string_literal: true

module Decidim
  module Proposals
    class CommentsCell < Decidim::Comments::CommentsCell
      def show
        render :show
      end
    end
  end
end
