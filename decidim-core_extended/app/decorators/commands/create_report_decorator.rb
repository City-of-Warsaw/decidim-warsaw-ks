# frozen_string_literal: true

Decidim::CreateReport.class_eval do
  def initialize(form, reportable, current_user)
    @form = form
    @reportable = reportable
    @current_user = current_user || unregistered_author
  end

  # Overwritten: add send_report_notification_to_author
  # Executes the command. Broadcasts these events:
  #
  # - :ok when everything is valid, together with the report.
  # - :invalid if the form wasn't valid and we couldn't proceed.
  #
  # Returns nothing.
  def call
    return broadcast(:invalid) if form.invalid?

    transaction do
      find_or_create_moderation!
      update_reported_content!
      create_report!
      update_report_count!
    end

    send_report_notification_to_moderators # template: resource_was_reported_to_moderators
    send_report_notification_to_author

    if hideable?
      hide!
      send_hide_notification_to_moderators
    end

    broadcast(:ok, report)
  end

  private

  def send_report_notification_to_author
    Decidim::ReportedMailer.notify_author(@report).deliver_later
  end

  def send_report_notification_to_moderators
    participatory_space_moderators.each do |moderator|
      next unless moderator.email_on_moderations

      Decidim::ReportedMailer.notify_moderator(moderator, @report).deliver_later
    end
  end

  # Overwritten
  # In KS only admins are notified
  def participatory_space_moderators
    @participatory_space_moderators ||= Decidim::User.admins
  end

  # Private method returning special object that serves as Author for reports created by unregistered users
  #
  # Sets first AD User as author of the report, to create it
  # User data is displayed based on
  def unregistered_author
    Decidim::User.where.not(ad_role: nil).first
  end

  def organization
    @reportable.try(:organization)
  end
end