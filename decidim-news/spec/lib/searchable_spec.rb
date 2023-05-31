# frozen_string_literal: true

require "rails_helper"

module Decidim
  describe Searchable do
    subject { described_class }
    # let(:organization) { create(:organization) }
    # let(:word) { ::Faker::Lorem.word }
    # let(:information) { Decidim::News::Information.create(title: 'Title', body: 'Body', organization: organization) }
    #
    # before do
    #   2.times { Decidim::News::Information.create(title: ::Faker::Lorem.word, body: ::Faker::Lorem.paragraph, organization: organization) }
    #   2.times { Decidim::News::Information.create(title: ::Faker::Lorem.word, body: ::Faker::Lorem.paragraph, organization: organization) }
    # end

    context "when searching for news" do
      it 'returns only informations' do
         expect(subject.searchable_resources_of_type_news.include?("Decidim::News::Information")).to be true
         expect(subject.searchable_resources_of_type_news.include?("Decidim::Comments::Comment")).to be false
         expect(subject.searchable_resources_of_type_news.include?("Decidim::User")).to be false
         expect(subject.searchable_resources_of_type_news.include?("Decidim::Component")).to be false
      end
    end
  end
end
