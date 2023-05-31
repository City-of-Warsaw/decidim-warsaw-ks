# frozen_string_literal: true

require "rails_helper"

module Decidim
  describe AccountForm do
    subject do
      described_class.new(
        name: name,
        email: email,
        nickname: nickname,
        password: password,
        password_confirmation: password_confirmation,
        avatar: avatar,
        remove_avatar: remove_avatar,
        personal_url: personal_url,
        about: about,
        # custom
        gender: gender,
        birth_year: birth_year,
        district: district,
        zip_code: zip_code
      ).with_context(
        current_organization: organization,
        current_user: user
      )
    end

    let(:user) { create(:user) }
    let(:organization) { user.organization }

    let(:name) { "Lord of the Foo" }
    let(:email) { "depths@ofthe.bar" }
    let(:nickname) { "foo_bar" }
    let(:password) { "Rf9kWTqQfyqkwseH" }
    let(:password_confirmation) { password }
    let(:avatar) { File.open("spec/assets/avatar.jpg") }
    let(:remove_avatar) { false }
    let(:personal_url) { "http://example.org" }
    let(:about) { "This is a description about me" }
    # custom
    let(:gender) { "male" }
    let(:birth_year) { 1990 }
    let(:district) { create(:scope, organization: organization) }
    let(:zip_code) { '23-345' }

    context "is valid" do
      it "with empty gender" do
        subject.gender = ''
        expect(subject).to be_valid
      end

      it "with empty birth_year" do
        subject.birth_year = nil
        expect(subject).to be_valid
      end

      it "with nil birth_year" do
        subject.birth_year = nil
        expect(subject).to be_valid
      end

      it "with birth_year set on 1900" do
        subject.birth_year = 1900
        expect(subject).to be_valid
      end

      it "with birth_year 1 years ago" do
        subject.birth_year = Date.current.year - 1
        expect(subject).to be_valid
      end

      it "with empty district" do
        subject.district = ''
        expect(subject).to be_valid
      end

      it "with nil district" do
        subject.district = nil
        expect(subject).to be_valid
      end

      it "with blank zip code" do
        subject.zip_code = ''
        expect(subject).to be_valid
      end

      it "with nil zip code" do
        subject.zip_code = nil
        expect(subject).to be_valid
      end

      it "with zip code: 02-480" do
        subject.zip_code = '02-480'
        expect(subject).to be_valid
      end

      it "prints errors when invalid" do
        subject.zip_code = '123-09'
        expect { (subject.errors.messages[:zip_code][0]).to eq(I18n.t('decidim.account.update.error')) }
      end
    end

    context "is invalid" do
      it "with birth_year 1899" do
        subject.birth_year = 1899
        expect(subject).to be_invalid
      end

      it "with birth_year this year" do
        subject.birth_year = Date.current.year
        expect(subject).to be_invalid
      end

      it "with not numerical birth_year" do
        subject.birth_year = 'milenium'
        expect(subject).to be_invalid
      end

      it "with invalid format of zip code" do
        subject.zip_code = 'kowalski'
        expect(subject).to be_invalid
      end
    end

    it "form do not accept ad_role" do
      expect { subject.ad_role }.to raise_error(NoMethodError)
    end
  end
end
