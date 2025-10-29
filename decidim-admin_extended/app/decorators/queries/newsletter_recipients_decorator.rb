# frozen_string_literal: true

Decidim::Admin::NewsletterRecipients.class_eval do
  # overwritten method
  # add additional scenarios
  def query
    recipients = Decidim::User.where(organization: @form.current_organization)
                              .not_deleted
                              .where.not(newsletter_notifications_at: nil, email: nil, confirmed_at: nil)

    if @form.scope_ids.present?
      recipients = recipients.interested_in_scopes(@form.scope_ids)
    end

    if @form.send_to_participants
      recipients = recipients.where(id: participant_ids)
    end

    if @form.send_to_followers
      recipients = Decidim::User.where(organization: @form.current_organization)
                                .not_deleted
                                .where.not(email: nil, confirmed_at: nil)
                                .where(id: user_id_of_followers)
    end

    if @form.send_to_tags
      ids = @form.tag_ids.map(&:to_i).join(',')
      recipients = recipients.where("extended_data->'interested_tags' @> ANY('{#{ids}}')")
    end

    if @form.send_to_type_ngo
      recipients = recipients.where(follow_ngo: true)
    end

    recipients
  end
end
