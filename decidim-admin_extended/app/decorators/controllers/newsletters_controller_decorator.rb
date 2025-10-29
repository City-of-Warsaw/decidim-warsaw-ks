# frozen_string_literal: true

Decidim::Admin::NewslettersController.class_eval do
  private

  # overwritten method
  # add additional_followers
  def recipients_count_query
    @form ||= form(Decidim::Admin::SelectiveNewsletterForm).instance
    recipients = Decidim::Admin::NewsletterRecipients.for(@form)
    recipients.size + additional_followers(recipients).size
  end

  def additional_followers(recipients)
    return [] unless @form.send_to_followers?

    type = @form.participatory_space_types.first
    return [] unless type&.manifest_name == "participatory_processes"

    process_ids = type.ids.presence || []
    emails = Decidim::ParticipatoryProcess.where(id: process_ids)
                                          .includes(:follows)
                                          .flat_map { |p| p.email_follows.map(&:email) }
                                          .uniq
    emails - recipients.map(&:email)
  end
end
