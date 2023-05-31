# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A command with all the business logic when creating a mail template.
    class UpdateMailTemplate < Rectify::Command
      # Public: Initializes the command.
      #
      # mail_template = MailTemplate object
      # form - A form object with the params.
      def initialize(mail_template, form)
        @mail_template = mail_template
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        update_mail_template
        broadcast(:ok)
      end

      private

      attr_reader :form, :mail_template

      # private method
      # updates mail template
      def update_mail_template
        Decidim.traceability.update!(
          mail_template,
          form.current_user,
          attributes
        )
      end

      # private method
      # maps mail template attributes provided by form
      # that can be updated
      #
      # returns Hash
      def attributes
        {
          name: form.name,
          subject: form.subject,
          body: form.body,
          active: form.active
        }
      end
    end
  end
end
