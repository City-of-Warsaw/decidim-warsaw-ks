# frozen_string_literal: true

Decidim::Admin::UserRolesHelper.class_eval do
  def user_role_config
    return @user_role_config if @user_role_config

    space = current_participatory_space
    @user_role_config = if current_user.ad_admin? || current_user.admin?
                          space.user_role_config_for(current_user, :organization_admin)
                        else
                          role = space.user_roles.find_by(user: current_user)
                          space.user_role_config_for(current_user, role&.role)
                        end
  end
end
