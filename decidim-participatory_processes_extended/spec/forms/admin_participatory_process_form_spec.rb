# frozen_string_literal: true

require "rails_helper"

module Decidim::ParticipatoryProcesses::Admin
  describe ParticipatoryProcessForm do
    subject do
      described_class.from_params(attributes).with_context(
        current_organization: current_organization
      )
    end

    let(:current_organization) { create(:organization) }

    let(:title) { { "pl" => "<p>Tytuł</p>", "en" => "<p>Title</p>" } }
    let(:subtitle) { { "pl" => "<p>SubTytuł</p>", "en" => "<p>SubTitle</p>" } }

    let(:short_description) { { "pl" => "<p>S Tresc</p>", "en" => "<p>S Content</p>" } }
    let(:description) { { "pl" => "<p>Tresc</p>", "en" => "<p>Content</p>" } }

    let(:start_date) { Date.current }
    let(:end_date) { Date.current + 1.year }
    let(:area) { create(:area, organization: current_organization) }

    let(:fb_url) { Faker::Internet.url(host: 'facebook', scheme: 'https') }

    let(:attributes) do
      {
        "participatory_process" => {
          "title" => title,
          "subtitle" => subtitle,
          "weight" => 3,
          "slug" => "new-process",
          "hashtag" => "hash",
          "short_description" => short_description,
          "description" => description,
          "start_date" => start_date,
          "end_date" => end_date,
          # hero_image: File.open("spec/assets/avatar.jpg"),
          "hero_image" => fixture_file_upload('spec/assets/avatar.jpg', 'image/jpeg'),
          # banner_image: File.open("spec/assets/avatar.jpg"),
          "banner_image" => fixture_file_upload('spec/assets/avatar.jpg', 'image/jpeg'),
          "promoted" => false,
          "scopes_enabled" => false,
          "area_id" => area.id,
          "fb_url" => fb_url
        }
      }
    end

    context "when everything is OK" do
      it { is_expected.to be_valid }
    end

    context "form_class" do
      it "constant RECIPIENTS has 3 elements" do
        expect(described_class::RECIPIENTS.size).to eq(3)
      end

      it "constant RECIPIENTS includes ngo value" do
        expect(described_class::RECIPIENTS).to include('ngo')
      end

      it "constant RECIPIENTS includes citizens value" do
        expect(described_class::RECIPIENTS).to include('citizens')
      end

      it "constant RECIPIENTS includes mix value" do
        expect(described_class::RECIPIENTS).to include('mix')
      end
    end

    context "form is valid" do
      it "with empty fb_url" do
        subject.fb_url = ''
        is_expected.to be_valid
      end

      it "with nil fb_url" do
        subject.fb_url = nil
        is_expected.to be_valid
      end

      it "with proper value for recipients" do
        subject.recipients = described_class::RECIPIENTS[rand(2)]
        is_expected.to be_valid
      end

      it "with empty recipients" do
        subject.recipients = ''
        is_expected.to be_valid
      end

      it "with nil recipients" do
        subject.recipients = nil
        is_expected.to be_valid
      end
    end

    context "form is not valid" do
      it "without http" do
        subject.fb_url = 'www.fb.com'
        is_expected.not_to be_invalid
      end

      it "with wrong " do
        subject.fb_url = 'http://www'
        is_expected.not_to be_invalid
      end

      it "with invalid string provided for recipients" do
        subject.recipients = 'false'
        is_expected.to be_invalid
      end

      it "with true recipients" do
        subject.recipients = true
        is_expected.to be_invalid
      end

      it "with false recipients" do
        subject.recipients = false
        is_expected.to be_invalid
      end
    end
  end
end
