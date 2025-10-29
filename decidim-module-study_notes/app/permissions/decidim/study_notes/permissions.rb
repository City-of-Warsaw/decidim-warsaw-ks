# frozen_string_literal: true

module Decidim
  module StudyNotes
    class Permissions < Decidim::DefaultPermissions
      def permissions
        return permission_action unless permission_action.subject.in?([:study_notes, :map_backgrounds, :categories, :legend_items])

        # Delegate the admin permission checks to the admin permissions class
        return Decidim::StudyNotes::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin

        return permission_action if permission_action.scope != :public

        allow!
        permission_action
      end
    end
  end
end
