# frozen_string_literal: true

# Class Decorator - Extending Decidim::ParticipatoryProcesses::Admin::PublishParticipatoryProcess
#
# Decorator implements additional functionalities to the Command
# and changes existing methods.
Decidim::ParticipatoryProcesses::Admin::PublishParticipatoryProcess.class_eval do

  # OVERWRITTEN DECIDIM METHOD
  #
  # Added new
  def call
    return broadcast(:invalid) if process.nil? || process.published?

    transaction do
      Decidim.traceability.perform_action!("publish", process, current_user, visibility: "all") do
        process.publish!
      end
      send_notification_about_published_process
      # TODO: we need to send email on report (waiting for MailTemplates)
      # send_report_notification if notification_about_report_should_be_sent?
    end


    broadcast(:ok)
  end

  private

  # Private method checking if notification about report should be send based on:
  # - report_notification_send_date is blank
  # - report_notification_send id true
  #
  # Returns Boolean
  def notification_about_report_should_be_sent?
    process.report_notification_send_date.blank? && process.report_notification_send.present?
  end

  def send_report_notification
    # send notifications
    # @participatory_process.update_column(report_notification_send_date: Date.current)
  end

  def send_notification_about_published_process
    Decidim::NotificationGeneratorJob.perform_later(
      "decidim.events.participatory_process.published",
      "Decidim::ParticipatoryProcessesExtended::ParticipatoryProcessPublishedEvent",
      process,
      process.find_published_process_followers.uniq.compact, # followers
      [], # affected_users
      {}
    )

    Decidim::CoreExtended::TemplatedMailerJob.perform_now('new_process_published', { resource: process })
  end
end