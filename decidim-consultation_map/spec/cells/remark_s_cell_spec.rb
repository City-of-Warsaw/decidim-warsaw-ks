# frozen_string_literal: true

require "rails_helper"
require "decidim/consultation_map/testing/factories"

module Decidim::ConsultationMap
  describe RemarkSCell, type: :cell do
    controller Decidim::ConsultationMap::RemarksController

    subject { my_cell.call }

    let(:my_cell) { cell("decidim/consultation_map/remark_s", map_remark) }
    let(:organization) { create(:organization) }
    let(:participatory_process) { create :participatory_process, organization: organization }
    let(:component) { create(:consultation_map_component, participatory_space: participatory_process) }
    let(:map_remark) { create(:map_remark, component: component, author: registered_author) }
    let(:registered_author) { create(:user, :confirmed, organization: organization, admin: false) }
    let(:editorial) { 'Redakcja' }

    context "when rendering with registered user as author" do
      context "when there is editorial" do
        it "renders the correct editorial" do
          expect(subject).to have_css(".author__name", text: registered_author.editorial)
        end
      end

      context "when editorial is empty" do
        let(:editorial) { '' }
        it "renders the registered author name" do
          expect(subject).to have_css(".author__name", text: registered_author.name)
        end
      end

      context "when editorial is nil" do
        let(:editorial) { nil }
        it "renders the registered author name" do
          expect(subject).to have_css(".author__name", text: registered_author.name)
        end
      end
    end
  end
end
