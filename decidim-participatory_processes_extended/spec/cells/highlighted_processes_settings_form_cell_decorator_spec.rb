# frozen_string_literal: true

require "rails_helper"

module Decidim
  module ParticipatoryProcesses
    module ContentBlocks
      describe HighlightedProcessesSettingsFormCell, type: :cell do
        
        let(:cell) { described_class.new }

        describe "max results label"
          subject { cell.label }

          it { is_expected.to eq("Maksymalna ilość elementów do pokazania") }
        end
      end
    end
  end
end
