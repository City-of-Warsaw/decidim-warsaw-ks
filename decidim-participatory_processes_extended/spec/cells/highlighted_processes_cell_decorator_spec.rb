# frozen_string_literal: true

require 'rails_helper'

module Decidim
  module ParticipatoryProcesses
    module ContentBlocks
      describe HighlightedProcessesCell, type: :cell do
        subject { cell(content_block.cell, content_block).call }

        let(:organization) { create(:organization) }
        let(:content_block) { create :content_block, organization: organization, manifest_name: :highlighted_processes, scope_name: :homepage, settings: settings }
        let!(:processes) { create_list :participatory_process, 15, organization: organization }
        let(:settings) { { } }
        let(:highlighted_processes) { subject.find('.upcoming-processes') }
        controller Decidim::HomepageController
    
        it 'tests correct amount of all created processes in db' do
          expect(Decidim::ParticipatoryProcess.count).to eq(15)
        end
        
        context 'when cell is rendered' do
          it 'shows only 3 elements, when the content block has no settings' do
            expect(highlighted_processes).to have_selector('a.card--process', maximum: 3)
          end 
        end
      
        context 'when the content block has customized the welcome text setting value' do
          let(:settings) {
            { 'max_results' => '3' }
          }

          it 'shows up to 3 processes' do
            expect(highlighted_processes).to have_selector('a.card--process', maximum: 3)
          end

          let(:settings) {
            { 'max_results' => '9' }
          }

          it 'shows up to 9 processes' do
            expect(highlighted_processes).to have_selector('a.card--process', maximum: 9)
          end
        end
      end
    end
  end
end
