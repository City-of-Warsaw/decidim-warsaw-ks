# frozen_string_literal: true

require "rails_helper"

module Decidim
  module Comments
    describe CreateComment do
      describe "call" do
        include_context "when creating a comment by unregistered user"

        describe "when the nesting is too deep" do
          let!(:first_comment) { create(:comment, commentable: dummy_resource) }
          let!(:second_comment) { create(:comment, commentable: first_comment) }
          let!(:third_comment) { create(:comment, commentable: second_comment) }
          let!(:commentable) { create(:comment, commentable: third_comment) }
          let(:command) { described_class.new(form, author) }

          xit "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          xit "doesn't create a comment" do
            expect do
              command.call
            end.not_to change(Comment, :count)
          end
        end

        describe "when the form is valid and the nesting is not too deep" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "creates a new comment" do
            expect(Decidim::Comments::Comment).to receive(:create!).with(
              author: default_author,
              signature: signature,
              commentable: commentable,
              root_commentable: commentable,
              body: { pl: body },
              alignment: alignment,
              decidim_user_group_id: user_group_id
            ).and_call_original

            expect do
              command.call
            end.to change(Decidim::Comments::Comment, :count).by(1)
          end

          it "creates a new searchable resource" do
            expect do
              perform_enqueued_jobs { command.call }
            end.to change(Decidim::SearchableResource, :count).by_at_least(1)
          end

          it "calls content processors" do
            user_parser = instance_double("kind of UserParser", users: [])
            user_group_parser = instance_double("kind of UserGroupParser", groups: [])
            parsed_metadata = { user: user_parser, user_group: user_group_parser }
            parser = instance_double("kind of parser", rewrite: "whatever", metadata: parsed_metadata)
            expect(Decidim::ContentProcessor).to receive(:parse).with(
              form.body,
              current_organization: form.current_organization
            ).and_return(parser)
            expect(Decidim::Comments::CommentCreation).to receive(:publish).with(a_kind_of(Decidim::Comments::Comment), parsed_metadata)

            command.call
          end

          it "sends the notifications" do
            creator_double = instance_double(NewCommentNotificationCreator, create: true)

            expect(NewCommentNotificationCreator)
              .to receive(:new)
              .with(kind_of(Decidim::Comments::Comment), [], [])
              .and_return(creator_double)

            expect(creator_double)
              .to receive(:create)

            command.call
          end

          it "does not trace the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:create!)
              .with(
                Decidim::Comments::Comment,
                default_author,
                kind_of(Hash),
                visibility: "public-only"
              )
              .and_call_original

            expect { command.call }.not_to change(Decidim::ActionLog, :count)
          end

          context "and comment contains a user mention" do
            let(:mentioned_user) { create(:user, organization: organization) }
            let(:parser_context) { { current_organization: organization } }
            let(:body) { ::Faker::Lorem.paragraph + " @#{mentioned_user.nickname}" }

            it "creates a new comment with user mention replaced" do
              expect(Decidim::Comments::Comment).to receive(:create!).with(
                author: default_author,
                signature: signature,
                commentable: commentable,
                root_commentable: commentable,
                body: { pl: Decidim::ContentProcessor.parse(body, parser_context).rewrite },
                alignment: alignment,
                decidim_user_group_id: user_group_id
              ).and_call_original

              expect do
                command.call
              end.to change(Decidim::Comments::Comment, :count).by(1)
            end

            it "sends the notifications" do
              creator_double = instance_double(NewCommentNotificationCreator, create: true)

              expect(NewCommentNotificationCreator)
                .to receive(:new)
                .with(kind_of(Comment), [mentioned_user], [])
                .and_return(creator_double)

              expect(creator_double)
                .to receive(:create)

              command.call
            end
          end

          context "and comment contains a group mention" do
            let(:mentioned_group) { create(:user_group, organization: organization) }
            let(:parser_context) { { current_organization: organization } }
            let(:body) { ::Faker::Lorem.paragraph + " @#{mentioned_group.nickname}" }

            it "creates a new comment with user_group mention replaced" do
              expect(Decidim::Comments::Comment).to receive(:create!).with(
                author: default_author,
                signature: signature,
                commentable: commentable,
                root_commentable: commentable,
                body: { pl: Decidim::ContentProcessor.parse(body, parser_context).rewrite },
                alignment: alignment,
                decidim_user_group_id: user_group_id
              ).and_call_original

              expect do
                command.call
              end.to change(Decidim::Comments::Comment, :count).by(1)
            end

            it "sends the notifications" do
              creator_double = instance_double(NewCommentNotificationCreator, create: true)

              expect(NewCommentNotificationCreator)
                .to receive(:new)
                .with(kind_of(Decidim::Comments::Comment), [], [mentioned_group])
                .and_return(creator_double)

              expect(creator_double)
                .to receive(:create)

              command.call
            end
          end
        end
      end
    end
  end
end
