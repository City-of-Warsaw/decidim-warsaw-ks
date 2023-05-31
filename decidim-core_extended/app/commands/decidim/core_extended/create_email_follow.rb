# frozen_string_literal: true

module Decidim::CoreExtended
  # A command with all the business logic for when a not registered user starts following a resource.
  class CreateEmailFollow < Rectify::Command
    # Public: Initializes the command.
    #
    # form         - A form object with the params.
    # current_user - The current user.
    def initialize(form)
      @form = form
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid, together with the follow.
    # - :invalid if the form wasn't valid and we couldn't proceed.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) if form.invalid?

      create_email_follow!

      broadcast(:ok, email_follow)
    end

    private

    attr_reader :email_follow, :form

    def create_email_follow!
      @email_follow = EmailFollow.find_or_create_by!(
        followable: form.followable,
        email: form.email
      )
    end

  end
end
