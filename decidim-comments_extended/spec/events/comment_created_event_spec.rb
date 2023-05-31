# frozen_string_literal: true

require "rails_helper"

describe Decidim::Comments::CommentCreatedEvent do
  include Rails.application.routes.mounted_helpers
  include_context "when it's a comment event"
  let(:event_name) { "decidim.events.comments.comment_created" }

  # it_behaves_like "a comment event"

  # let(:new_resource) { comment.commentable }

  let(:organization) { create(:organization) }
  let(:participatory_process) { create :participatory_process, organization: organization }
  let(:component) { create(:component, manifest_name: "meetings", participatory_space: participatory_process) }
  let(:resource) { create(:meeting, component: component) }
  let(:default_author) { Decidim::CommentsExtended::UnregisteredAuthor.find_by(organization_id: organization.id) }
  let(:user) { create(:user, :confirmed, locale: "en", organization: organization) }
  let(:comment) { create(:comment, commentable: resource, author: default_author, signature: signature) }
  let(:signature) { nil }

  describe "email data" do
    context 'when comment has no signature' do

      it "email_subject is generated correctly when there is no signature" do
        author_name = t("decidim.comments_extended.models.comment.fields.unregistered_author_mail")
        final_email_subject = t("decidim.events.comments.comment_created.email_subject").gsub('%{author_name}', author_name).gsub('%{resource_title}', resource_title)
        expect(subject.email_subject).to eq(final_email_subject)
      end

      it "email_intro is generated correctly when there is no signature" do
        final_email_intro = t("decidim.events.comments.comment_created.email_intro").gsub('%{resource_title}', resource_title)
        expect(subject.email_intro).to eq(final_email_intro)
      end

      it "email_outro is generated correctly when there is no signature" do
        final_email_outro = t("decidim.events.comments.comment_created.email_outro").gsub('%{resource_title}', resource_title)
        expect(subject.email_outro).to eq(final_email_outro)
      end

      it "notification_title is generated correctly when there is no signature" do
        signature ||= ''
        author_name = t("decidim.comments_extended.models.comment.fields.unregistered_author_mail")
        comment_path = "#{resource_path}#comment_#{comment.id}"
        final_notification_title = t("decidim.events.comments.comment_created.notification_title")
                                    .gsub('%{author_name}', author_name)
                                    .gsub('%{author_nickname}', signature)
                                    .gsub('%{resource_title}', resource_title)
                                    .gsub('%{resource_path}', comment_path)
                                    .gsub('%{author_path}', comment_path)
        expect(subject.notification_title).to eq(final_notification_title)
      end
    end

    context 'when comment has a signature' do
      let(:signature) { ::Faker::Lorem.word }

      it "email_subject is generated correctly when there is no signature" do
        author_name = t("decidim.comments_extended.models.comment.fields.unregistered_author_mail")
        final_email_subject = t("decidim.events.comments.comment_created.email_subject").gsub('%{author_name}', author_name).gsub('%{resource_title}', resource_title)
        expect(subject.email_subject).to eq(final_email_subject)
      end

      it "email_intro is generated correctly when there is no signature" do
        final_email_intro = t("decidim.events.comments.comment_created.email_intro").gsub('%{resource_title}', resource_title)
        expect(subject.email_intro).to eq(final_email_intro)
      end

      it "email_outro is generated correctly when there is no signature" do
        final_email_outro = t("decidim.events.comments.comment_created.email_outro").gsub('%{resource_title}', resource_title)
        expect(subject.email_outro).to eq(final_email_outro)
      end

      it "notification_title is generated correctly when there is no signature" do
        author_name = t("decidim.comments_extended.models.comment.fields.unregistered_author_mail")
        comment_path = "#{resource_path}#comment_#{comment.id}"
        final_notification_title = t("decidim.events.comments.comment_created.notification_title")
                                    .gsub('%{author_name}', author_name)
                                    .gsub('%{author_nickname}', '')
                                    .gsub('%{resource_title}', resource_title)
                                    .gsub('%{resource_path}', comment_path)
                                    .gsub('%{author_path}', comment_path)
        expect(subject.notification_title).to eq(final_notification_title)
      end
    end
  end
end
