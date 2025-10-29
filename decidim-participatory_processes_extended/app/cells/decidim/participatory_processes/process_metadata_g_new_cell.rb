# frozen_string_literal: true
# file overritten to hide step name on process cards

require "cell/partial"

module Decidim
  module ParticipatoryProcesses
    class ProcessMetadataGNewCell < Decidim::ParticipatoryProcesses::ProcessMetadataGCell
      private

      def items
        [progress_item].compact
      end
    end
  end
end
