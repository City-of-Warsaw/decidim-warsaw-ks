# frozen_string_literal: true

module Decidim
  module Remarks
    class CommentsCell < Decidim::Comments::CommentsCell
      def show
        render :show
      end
    end
  end
end
