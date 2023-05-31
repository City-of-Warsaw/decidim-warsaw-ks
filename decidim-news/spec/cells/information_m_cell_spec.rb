# frozen_string_literal: true

require "rails_helper"

describe Decidim::News::InformationMCell, type: :cell do
  controller Decidim::News::InformationsController

  subject { my_cell.call }

  let(:my_cell) { cell("decidim/news/information_m", information) }

  let(:organization) { create(:organization) }
  let(:information) { Decidim::News::Information.create(title: 'Title', body: long_body, organization: organization) }
  let(:path) { Decidim::News::Engine.routes.url_helpers.news_path(information) }
  let(:long_body) { ::Faker::Lorem.paragraphs }


  context "when cell is rendered" do
    it "shows the default route to information" do
      expect(my_cell.resource_path).to eq(path)
      expect(subject).to have_css("a[href='#{path}']")
    end

    it "shows proper links" do
      expect(my_cell.resource_path).to eq(path)
      expect(subject).to have_css("a[href='#{path}']")
    end

    it "shows trunkated body" do
      expect(subject).to have_text(information.body.first(50))
      expect(subject).not_to have_text(information.body.first(51))
    end
  end

end
