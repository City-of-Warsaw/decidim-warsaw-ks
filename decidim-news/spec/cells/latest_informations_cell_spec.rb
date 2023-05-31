# frozen_string_literal: true

require "rails_helper"

describe Decidim::News::ContentBlocks::LatestInformationsCell, type: :cell do
  controller Decidim::HomepageController

  subject { my_cell.call }

  let(:my_cell) { cell("decidim/news/content_blocks/latest_informations") }

  let(:organization) { create(:organization) }
  let(:path) { Decidim::News::Engine.routes.url_helpers.news_index_path }


  context "when cell is rendered" do
    before do
      6.times { Decidim::News::Information.create(title: ::Faker::Lorem.word, body: ::Faker::Lorem.paragraph, organization: organization) }
    end

    it 'has proper path for all elements' do
      expect(my_cell.all_news_path).to eq(path)
    end

    it 'shows only 3 elements' do
      expect(my_cell.latest_informations.count).to eq(3)
    end

    it 'shows only 3 elements' do
      expect(subject).to have_css(".latest-informations")
      expect(subject).to have_css(".card--information", count: 3)
      expect(subject).to have_css("a[href='#{path}']")
    end

  end

  context "when there are no informations" do
    it "shows the default route to information" do
      expect(my_cell.latest_informations.blank?).to be true
      expect(subject).to have_no_css(".latest-informations")
    end
  end

end
