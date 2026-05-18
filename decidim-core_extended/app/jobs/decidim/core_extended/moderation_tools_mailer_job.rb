# frozen_string_literal: true

module Decidim
  module CoreExtended
    # This job is used to queue the mail produced by decidim create report if resource was hidden
    # It is using template defined in admin panel.
    class ModerationToolsMailerJob < ApplicationJob
      include Decidim::EmailChecker

      queue_as :events

      def perform(action_name, resource, receiver, form_details)
        Rails.logger.debug { "[ModerationToolsMailerJob] init perform" }
        Rails.logger.debug { "[ModerationToolsMailerJob] receiver: #{receiver.inspect}, resource: #{resource.inspect}" }

        email = receiver.respond_to?(:email) ? receiver.email : receiver[:email]

        Rails.logger.debug { "[ModerationToolsMailerJob] Receiver #{receiver.inspect} - Email: #{email} - Valid? #{valid_email?(email)}" }
        return unless valid_email?(email)

        reported_content = resource.moderation.reported_content
        report_reasons = resource.moderation.reports.pluck(:reason).uniq

        Rails.logger.debug { "[ModerationToolsMailerJob] init TemplatedMailer.notify" }
        Decidim::CoreExtended::TemplatedMailer.notify(
          action_name, receiver, { resource:, report_reasons:, reported_content:, report_details: [form_details] }
        ).deliver_later
      end
    end
  end
end
