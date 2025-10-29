# frozen_string_literal: true

Decidim::Admin::NewsletterJob.class_eval do
  queue_as :newsletter
  include Decidim::EmailChecker

  def perform(newsletter, form, recipients_ids)
    @newsletter = newsletter
    @form = form
    @recipients_ids = recipients_ids
    @additional_followers = find_email_follows

    @newsletter.with_lock do
      raise 'Newsletter already sent' if @newsletter.sent?

      @newsletter.update!(
        sent_at: Time.current,
        extended_data: extended_data,
        total_recipients: recipients.count + @additional_followers.count,
        total_deliveries: 0
      )
    end

    @additional_followers.each do |email|
      # for check invalid emails
      unless valid_email?(email)
        Sentry.capture_message("Incorrect email from additional newletter #{email}")
        next
      end

      Decidim::NewsletterMailer.newsletter_without_account(email, @newsletter).deliver_later

      @newsletter.with_lock do
        @newsletter.increment!(:total_deliveries)
      end
    end

    recipients.find_each do |user|
      # for check invalid emails
      unless valid_email?(user.email)
        Sentry.capture_message("Incorrect email from newletter #{user.email}")
        next
      end
      Decidim::NewsletterMailer.newsletter(user, @newsletter).deliver_later

      @newsletter.with_lock do
        @newsletter.increment!(:total_deliveries)
      end
    end
  end

  private

  # return uniq email addresses from process followers without already existing emails in users accounts
  def find_email_follows
    return [] unless @form['send_to_followers']
    return [] unless @form['participatory_space_types']&.first['manifest_name'] == 'participatory_processes'

    email_follows = Decidim::ParticipatoryProcess.where(id: @form['participatory_space_types']&.first['ids'])
                                                 .map { |process| process.email_follows.map(&:email) }
                                                 .flatten.uniq
    email_follows - recipients.map(&:email)
  end

  def extended_data
    {
      send_to_all_users: @form['send_to_all_users'],
      send_to_followers: @form['send_to_followers'],
      send_to_type_ngo: @form['send_to_type_ngo'],
      send_to_tags: @form['send_to_tags'],
      tag_ids: @form['tag_ids'],
      send_to_participants: @form['send_to_participants'],
      participatory_space_types: @form['participatory_space_types'],
      scope_ids: @form['scope_ids'],
      additional_followers: @additional_followers.count
    }
  end
end
