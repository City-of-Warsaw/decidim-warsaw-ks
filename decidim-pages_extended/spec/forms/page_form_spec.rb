# frozen_string_literal: true

require "rails_helper"

module Decidim::Pages::Admin
  describe PageForm do
    subject do
      described_class.from_params(attributes).with_context(
        current_organization: current_organization
      )
    end

    let(:current_organization) { create(:organization) }

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

    let(:commentable) { true }

    let(:attributes) do
      {
        "page" => {
          "title" => title,
          "body" => body,
          "commentable" => commentable
        }
      }
    end

    context "when everything is OK" do
      it { is_expected.to be_valid }
    end

    context "form is not valid" do
      it "with empty title" do
        subject.title = { }
        is_expected.to be_invalid
      end

      it "with empty title locales" do
        subject.title = { pl: ' ', en: '' }
        is_expected.to be_invalid
      end

      it "with nil title" do
        subject.title = nil
        is_expected.to be_invalid
      end
    end
  end
end
