# frozen_string_literal: true

require "rails_helper"

module Decidim
  describe Organization do
    subject(:organization) { build(:organization) }

    it 'creates unregistered author on save' do
      expect(Decidim::CommentsExtended::UnregisteredAuthor.all.none?).to be true

      subject.save
      expect(Decidim::CommentsExtended::UnregisteredAuthor.all.none?).to be false
      expect(Decidim::CommentsExtended::UnregisteredAuthor.where(organization: subject).none?).to be false
    end
  end
end
