# frozen_string_literal: true

require "rails_helper"

module Decidim::Remarks
  describe Remark do
    let(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, organization: organization) }
    let(:user) { create :user, :confirmed, organization: organization }
    let(:component) { create :remarks_component, participatory_space: participatory_process }
    let(:email) { nil }
    let(:default_author) { organization.unregistered_author }

    let(:author) { user }

    let!(:remark) do
      create(
        :remark,
        component: component,
        author: author
      )
    end

    context 'for added question' do
      it 'shows proper belonging values' do
        expect(remark.component).to eq(component)
        expect(remark.author).to eq(user)
        # methods
        expect(remark.organization).to eq(organization)
        expect(remark.participatory_space).to eq(participatory_process)
      end

      it 'is commentable' do
        expect(remark.private_space?).to be false
        expect(remark.allowed_to_comment?(default_author)).to be true
        expect(remark.allowed_to_comment?(user)).to be true
      end

      it 'users_to_notify_on_comment_created returns participatory space followers' do
        users = remark.users_to_notify_on_comment_created
        component.participatory_space.followers.each do |f|
          expect(users.include?(f)).to be false
        end
      end

      it 'returns proper users_to_notify_on_comment_created' do
        # TODO: when followable will acknowlede unregistered users
        users = remark.users_to_notify_on_comment_created
        expect(users.include?(remark.author)).to be true
      end

      context 'for unregistered author' do
        let(:user) { default_author }
        xit 'returns proper users_to_notify_on_comment_created' do
          # TODO: when followable will acknowlede unregistered users
          users = remark.users_to_notify_on_comment_created
          expect(users.include?(user)).to be true
        end
      end
    end

    context 'when author is unregistered user' do
      let(:remark_new) { described_class.new(component: component, author: default_author, body: body) }
      let(:body) { ::Faker::Lorem.sentence }

      it 'is valid' do
        expect(remark_new.valid?).to be true
      end
    end
  end
end
