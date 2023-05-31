# frozen_string_literal: true

require "rails_helper"

module Decidim
  describe User do
    let(:organization) { create(:organization)}
    let(:user) { create(:user, :confirmed, organization: organization, gender: 'male', birth_year: 1999, district: create(:scope, organization: organization) ) }

    context "user is valid" do
      it 'has no gender' do
        user.gender = ''
        expect(user).to be_valid
      end

      it 'has no birth_year' do
        user.birth_year = nil
        expect(user).to be_valid
      end

      it 'has no district' do
        user.district = nil
        expect(user).to be_valid
      end
    end

    context "user has AD role" do
      it '#ad_admin?' do
        user.ad_role = 'Decidim_ks_admin'
        expect(user.ad_admin?).to be true
        expect(user.has_ad_role?).to be true
      end

      it '#ad_coordinator?' do
        user.ad_role = 'Decidim_ks_koordynator'
        expect(user.ad_coordinator?).to be true
        expect(user.has_ad_role?).to be true
      end

      it '#ad_moderator?' do
        user.ad_role = 'Decidim_ks_moderator'
        expect(user.ad_moderator?).to be true
        expect(user.has_ad_role?).to be true
      end

      it '#ad_expert?' do
        user.ad_role = 'Decidim_ks_ekspert'
        expect(user.ad_expert?).to be true
        expect(user.has_ad_role?).to be true
      end
    end

    context 'user has no AD role' do
      it 'when ad_role not defined' do
        user.ad_role = 'random'
        expect(user.has_ad_role?).to be false
      end

      it 'when ad_role empty' do
        user.ad_role = ' '
        expect(user.has_ad_role?).to be false
      end

      it 'when ad_role nil' do
        user.ad_role = nil
        expect(user.has_ad_role?).to be nil
      end
    end

    context 'user has ad_role set with' do
      xit '#assign_ad_role!(Decidim_ks_admin)' do
        expect(user.has_ad_role?).to be false
        expect(user.ad_admin?).to be false
        expect(user.admin).to be false
        user.assign_ad_role!('Decidim_ks_admin')
        user.reload
        expect(user.has_ad_role?).to be true
        expect(user.admin).to be true
      end

      xit '#assign_ad_role!(Decidim_ks_koordynator)' do
        user.assign_ad_role!('Decidim_ks_koordynator')
        user.reload
        expect(user.has_ad_role?).to be true
        expect(user.ad_coordinator?).to be true
        expect(user.admin).to be false
      end

      xit '#assign_ad_role!(Decidim_ks_moderator)' do
        user.assign_ad_role!('Decidim_ks_moderator')
        user.reload
        expect(user.has_ad_role?).to be true
        expect(user.ad_moderator?).to be true
        expect(user.admin).to be false
      end

      xit '#assign_ad_role!(Decidim_ks_ekspert)' do
        user.assign_ad_role!('Decidim_ks_ekspert')
        user.reload
        expect(user.has_ad_role?).to be true
        expect(user.ad_expert?).to be true
        expect(user.admin).to be false
      end
    end

    context 'user has not ad_role set' do
      xit 'with wrong name' do
        expect(user.assign_ad_role!('Decidim_ks_random')).to be_nil
        user.reload
        expect(user.has_ad_role?).to be false
        expect(user.admin).to be false
      end

      xit 'with empty value passed' do
        expect(user.assign_ad_role!(' ')).to be_nil
        user.reload
        expect(user.has_ad_role?).to be false
        expect(user.admin).to be false
      end

      xit 'with nil value passed' do
        expect(user.assign_ad_role!(nil)).to be_nil
        user.reload
        expect(user.has_ad_role?).to be false
        expect(user.admin).to be false
      end
    end
  end
end
