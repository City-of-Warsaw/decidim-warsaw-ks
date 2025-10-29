# frozen_string_literal: true

module Decidim
  module CustomProposals
    module AdminLog
      # This class holds the logic to present a `Decidim::CustomProposals::CustomProposal`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    CustomProposalPresenter.new(action_log, view_helpers).present
      class CustomProposalPresenter < Decidim::Log::BasePresenter

        private

        def diff_fields_mapping
          {
            title: :string,
            body: :text,
            published: :boolean,
            weight: :integer
          }
        end

        def action_string
          case action
          when "create", "update", "delete"
            "decidim.admin_log.custom_proposal.#{action}"
          else
            super
          end
        end

        def i18n_labels_scope
          "activemodel.attributes.custom_proposal"
        end

        def diff_actions
          super + %w(delete)
        end
      end
    end
  end
end
