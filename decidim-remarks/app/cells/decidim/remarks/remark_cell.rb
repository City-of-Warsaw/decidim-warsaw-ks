# frozen_string_literal: true

module Decidim
  module Remarks
    class RemarkCell < Decidim::ViewModel
      def show
        cell card_size, model, options
      end

      private

      def card_size
        case @options[:size]
        when :l
          "decidim/remarks/remark_l"
        else
          "decidim/remarks/remark_s"
        end
      end
    end
  end
end
