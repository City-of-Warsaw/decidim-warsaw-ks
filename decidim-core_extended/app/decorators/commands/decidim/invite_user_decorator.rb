# frozen_string_literal: true

Decidim::InviteUser.class_eval do
    # Public: Initializes the command.
    #
    # form - A form object with the params.
    def initialize(form)
      @form = form
    end

    def call
      return broadcast(:invalid) if form.invalid?

      if user.present?
        update_user
      else
        invite_user
      end

      update_user_admin

      broadcast(:ok, user)
    end

    private
    def update_user_admin
      @accepting_invitation = true
      if user.admin
        user.admin_terms_accepted_at = Time.now
        user.ad_role = "first_admin"
        user.ad_name = "first_admin_#{SecureRandom.hex(4)}"
        user.save!
      end
    end
end
