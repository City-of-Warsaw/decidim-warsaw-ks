# frozen_string_literal: true

require "rails_helper"

module Decidim::Pages
  describe Page do
    subject do
      create :page, component: current_component, title: title, body: body, published_at: published_at
    end

    let(:organization) { create(:organization) }
    let(:participatory_process) { create :participatory_process, organization: organization }
    let(:current_component) { create :component, participatory_space: participatory_process, manifest_name: "pages" }

    let(:title) do
      {
        "pl" => "<p>Tytuł</p>",
        "en" => "<p>Title</p>"
      }
    end

    let(:body) do
      {
        "pl" => "<p>Tresc</p>",
        "en" => "<p>Content</p>"
      }
    end

    let(:published_at) { Date.current }

    context "when all data is presented" do
      it { is_expected.to be_valid }
    end

    context "page is not valid" do
      it "with empty title" do
        subject.title = { }
        is_expected.to be_invalid
      end

      it "with nil title" do
        subject.title = nil
        is_expected.to be_invalid
      end
    end

    it 'returns proper participatory space' do
      expect(subject.participatory_space).to eq participatory_process
    end

    it 'returns proper title' do
      expect(subject.title).to eq title
      expect(subject.title).not_to eq current_component.name
    end

    context 'page has published_at set' do
      it 'is published' do
        expect(subject.published?).to be true
      end
    end

    context 'page has published_at set' do
      let(:published_at) { nil }
      it 'is not published' do
        expect(subject.published?).to be false
      end
    end
  end
end
