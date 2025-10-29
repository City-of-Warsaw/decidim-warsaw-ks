# frozen_string_literal: true

module Decidim
  module News
    module Admin
      class Permissions < Decidim::Admin::Permissions
        def permissions
          return permission_action unless user
          return permission_action unless permission_action.scope == :admin

          # allow for all ad_admins
          toggle_allow(user.ad_admin?)

          permission_action
        end
      end
    end
  end
end
