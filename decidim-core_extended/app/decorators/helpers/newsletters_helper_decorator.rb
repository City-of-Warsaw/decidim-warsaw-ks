# frozen_string_literal: true

Decidim::NewslettersHelper.class_eval do

    # If the newsletter body there are some links and the Decidim.track_newsletter_links = true
    # it will be replaced with the utm_codes method described below.
    # for example transform "https://es.lipsum.com/" to "https://es.lipsum.com/?utm_source=localhost&utm_campaign=newsletter_11"
    # And replace "%{name}" on the subject or content of newsletter to the user Name
    # and replace "%{unsubscribe_link}" on the subject or content of newsletter to the proper unsubscribe newsletter link
    # for example transform "%{name}" to "User Name"
    #
    # @param content [String] - the string to convert
    # @param user [Decidim::User] - the user to replace
    # @param id [Integer] - the id of the newsletter to change
    #
    # @return [String] - the content converted
    def parse_interpolations(content, user = nil, id = nil)
      host = user&.organization&.host&.to_s

      content = interpret_name(content, user)
      content = interpret_unsubscribe_link(content, user, host)
      content = track_newsletter_links(content, id, host)
      transform_image_urls(content, host)
    end

    # Interpret placeholder '%{unsubscribe_link}' and replace by the proper linkk for unsubscribe
    # If user is not define, it returns content with blank instead of the placeholder
    #
    # @param content [String] - the string to convert
    # @param user [Decidim::User] - the user to replace
    #
    # @return [String] - the content converted
    #
    def interpret_unsubscribe_link(content, user, host)
      return content.gsub("%{unsubscribe_link}", "_dummy_url_") if user.blank?

      content.gsub("%{unsubscribe_link}",unsubscribe_link(user,host))
    end

    def unsubscribe_link(user, host)
      encrypted_token = Decidim::NewsletterEncryptor.sent_at_encrypted(user.id, user.class.to_s, 'newsletter')
      decidim.unsubscribe_newsletters_url(host: host, u: encrypted_token )
    end
end
