# frozen_string_literal: true

require "rails_helper"

module Decidim
  module AdminExtended
    describe BannedWordForm do
      subject { described_class.new(name: name) }

      let(:name) { ::Faker::Lorem.word }

      it "is valid" do
        expect(subject).to be_valid
      end

      context "is invalid with empty name" do
        let(:name) { '' }

        it { expect(subject).not_to be_valid }
      end

      context "empty hash, without error messages, when form is correct" do
        let(:name) { 'cat' }

        it { expect(subject.errors.messages).to be_empty }
      end

      context "specific errors for specific attributes" do
        let(:name) { nil }
      
        it { expect { (subject.errors.messages[:name][0]).to eq('Nazwa nie może być puste') }}
      end
    end
  end
end
