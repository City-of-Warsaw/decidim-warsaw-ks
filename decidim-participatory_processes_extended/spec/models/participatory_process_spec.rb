# frozen_string_literal: true

require "rails_helper"

module Decidim
  describe ParticipatoryProcess do
    subject do
      create :participatory_process, organization: organization
    end
    let(:organization) { create(:organization) }

    let(:fb_url) { Faker::Internet.url(host: 'facebook', scheme: 'https') }
    let(:random_url) { Faker::Internet.url(scheme: 'https') }
    let(:http_url) { Faker::Internet.url(scheme: 'http') }

    context "when all data is presented" do
      it { is_expected.to be_valid }
    end

    context "process is valid" do
      it "with fb url" do
        subject.fb_url = fb_url
        is_expected.to be_valid
      end

      it "with random url" do
        subject.fb_url = random_url
        is_expected.to be_valid
      end

      it "with http url" do
        subject.fb_url = http_url
        is_expected.to be_valid
      end

      it "when recipients value is provided" do
        subject.recipients = 'ngo'
        is_expected.to be_valid
      end

      it "when recipients value empty provided" do
        subject.recipients = ''
        is_expected.to be_valid
      end
    end
  end
end
