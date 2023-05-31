# frozen_string_literal: true

require "rails_helper"

module Decidim::News
  describe Information do
    subject(:information) { Decidim::News::Information.create(title: 'Title', body: 'Body', organization: organization) }

    let(:organization) { create :organization }
    let(:user) { create :user, :admin, :confirmed, admin: false, organization: organization, ad_role: 'decidim_ks_cks_admin' }
    let(:users) do
      5.times { create :user, :confirmed, organization: organization }
      Decidim::User.all
    end

    it 'can be commented' do
      expect(subject.allowed_to_comment?(nil)).to be true
      expect(subject.allowed_to_comment?(user)).to be true
    end

    it 'has searchable results' do
      expect(subject.respond_to?(:searchable_resources)).to be true
      expect(subject.searchable_resources.any?).to be true
    end

    it 'has attachments' do
      expect(subject.respond_to?(:attachments)).to be true
    end

    it 'has attachment collections' do
      expect(subject.respond_to?(:attachment_collections)).to be true
    end

    it 'maps proper data' do
      expect(subject.class.search_resource_fields_mapper.mapped(subject)[:decidim_participatory_space_type]).to eq(subject.class.name)
      expect(subject.class.search_resource_fields_mapper.mapped(subject)[:decidim_participatory_space_id]).to eq(subject.id)
      expect(subject.class.search_resource_fields_mapper.mapped(subject)[:decidim_organization_id]).to eq(organization.id)

      expect(subject.class.search_resource_fields_mapper.mapped(subject)[:i18n]['pl'][:A]).to eq(subject.title)
      expect(subject.class.search_resource_fields_mapper.mapped(subject)[:i18n]['pl'][:B]).to be nil
      expect(subject.class.search_resource_fields_mapper.mapped(subject)[:i18n]['pl'][:C]).to be nil
      expect(subject.class.search_resource_fields_mapper.mapped(subject)[:i18n]['pl'][:D]).to eq(subject.body)
    end

    context 'followers are notices on create' do
      let(:followers_list) { subject.followers } # TODO: dodac unregistered users

      it 'returns list of all followers' do
         users.each do |u|
          create :follow, user: u, followable: subject
        end

        expect(subject.users_to_notify_on_comment_created).to eq(followers_list)
        expect(subject.follows_count).to eq(5)
      end
    end
  end
end
