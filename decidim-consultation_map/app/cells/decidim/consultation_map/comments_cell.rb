# frozen_string_literal: true

module Decidim
  module ConsultationMap
    class CommentsCell < Decidim::Comments::CommentsCell

      def show
        render :show
      end

      def node_id
        "comments-for-#{commentable_type.demodulize}-#{model.id}#{for_reader}"
      end

      def for_reader
        @options[:for_reader]
      end
    end
  end
end
