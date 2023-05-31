# frozen_string_literal: true

require "rails_helper"

module Decidim
  module CommentsExtended
    describe UpdateComment do
      describe "call" do
        include_context "when updating a comment"

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "updates comment" do
            expect(comment).to receive(:update).with(
              email: email,
              age: age,
              gender: gender,
              district: district
            ).and_call_original

            expect do
              command.call
            end.not_to change(Decidim::Comments::Comment, :count)
          end

          it "updates does not change the searchable resource" do
            # we do not update cause additional data is for admin only

            # searchable = SearchableResource.find_by(resource_type: comment.class.name, resource_id: comment.id)
            # created_at = searchable.created_at
            # updated_title = Decidim::Faker::Localized.name

            expect do
              perform_enqueued_jobs { command.call }
            end.not_to change(Decidim::SearchableResource, :count)

            # searchable.reload
            # organization.available_locales.each do |locale|
            #   searchable = SearchableResource.find_by(resource_type: comment.class.name, resource_id: comment.id, locale: locale)
            #   expect(searchable.content_a).to eq I18n.transliterate(translated(updated_title, locale: locale))
            #   expect(searchable.updated_at).to be > created_at
            # end
          end
        end
      end
    end
  end
end
