# frozen_string_literal: true

require "rails_helper"

module Decidim::CommentsExtended
  describe UnregisteredAuthorPresenter, type: :helper do

    let(:organization) { create(:organization) }
    let(:default_author) { Decidim::CommentsExtended::UnregisteredAuthor.find_by(organization_id: organization.id) }
    let(:params) do
      {
        signature: signature,
        name_param: name_param

      }
    end

    let(:signature) { nil }
    let(:name_param) { nil }

    context "with no params" do
      subject { described_class.new.name }

      it { is_expected.to eq(I18n.t("decidim.comments_extended.models.comment.fields.unregistered_author")) }
    end

    context "with params signature" do
      let(:signature) { 'signature' }
      subject { described_class.new(params).name }

      it { is_expected.to eq(I18n.t("decidim.comments_extended.models.comment.fields.unregistered_author")) }
    end

    context "with params signature and mail name_param" do
      let(:signature) { 'signature' }
      let(:name_param) { 'mail' }

      subject { described_class.new(params).name }

      it { is_expected.to eq(I18n.t("decidim.comments_extended.models.comment.fields.unregistered_author_mail")) }
    end

    context "with params signature and sign name_param" do
      let(:signature) { 'signature' }
      let(:name_param) { 'signed' }
      subject { described_class.new(params).name }

      it { is_expected.to eq(signature) }
    end

    context "with params signature and wrong name_param" do
      let(:signature) { 'signature' }
      let(:name_param) { 'wrong' }
      subject { described_class.new(params).name }

      it { is_expected.to eq(I18n.t("decidim.comments_extended.models.comment.fields.unregistered_author")) }
    end
  end
end
