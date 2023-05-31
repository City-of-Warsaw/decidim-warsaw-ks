# frozen_string_literal: true

require "rails_helper"

module Decidim::CommentsExtended
  describe UnregisteredAuthor do
    subject(:author) { default_author }

    let(:organization) { create(:organization) }
    let(:default_author) { Decidim::CommentsExtended::UnregisteredAuthor.find_by(organization_id: organization.id) }

    it 'belongs to organization' do
      expect(subject.organization == organization).to be true
    end

    it 'returns false on deleted?' do
      expect(subject.deleted?).to be false
    end

    it 'has presenter set' do
      expect(subject.presenter.class.name).to be_equal Decidim::CommentsExtended::UnregisteredAuthorPresenter.name
    end

    context 'when organization has ad_admins' do
      let!(:ad_admin) { create :user, :admin, admin: false, ad_role: 'decidim_ks_cks_admin', organization: organization }
      let!(:admin) { create :user, :admin, organization: organization }
      let!(:ad_admin_outside) { create :user, :admin }

      it 'has followers' do
        expect(subject.followers.count == 1).to be true

        expect(subject.followers.include? ad_admin).to be true
        expect(subject.followers.include? admin).to be false
        expect(subject.followers.include? ad_admin_outside).to be false
      end
    end
  end
end
