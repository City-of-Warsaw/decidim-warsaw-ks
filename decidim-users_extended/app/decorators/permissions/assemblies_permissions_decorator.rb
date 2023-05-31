# frozen_string_literal: true

Decidim::Assemblies::Permissions.class_eval do
  def permissions
    disallow!

    permission_action
  end
end
