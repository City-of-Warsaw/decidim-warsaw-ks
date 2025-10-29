# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A form object to update Admin.
    class AdminUserForm < Form
      attribute :editorial, String

      mimic :user

      validates :editorial, presence: true
    end
  end
end
