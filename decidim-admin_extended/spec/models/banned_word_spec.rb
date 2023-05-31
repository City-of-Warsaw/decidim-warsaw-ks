# frozen_string_literal: true
require 'rails_helper'

module Decidim
  module AdminExtended
    describe BannedWord, type: :model do

      let(:banned_word) { Decidim::AdminExtended::BannedWord.create(name: 'Name') }

      context "Banned Word scopes" do
        it "is scope which sorts records by name" do
          expect(Decidim::AdminExtended::BannedWord.sorted_by_name).to eq(Decidim::AdminExtended::BannedWord.order(:name))
        end

        it "is not scope which sorts records by creation date" do
          expect(Decidim::AdminExtended::BannedWord.sorted_by_name).not_to eq(Decidim::AdminExtended::BannedWord.order(:created_at))
        end
      end
    end
  end
end
