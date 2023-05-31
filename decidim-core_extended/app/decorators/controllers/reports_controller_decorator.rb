# frozen_string_literal: true

Decidim::ReportsController.class_eval do
  skip_before_action :authenticate_user!

  def permission_class_chain
    if reportable.root_commentable && reportable.root_commentable.is_a?(Decidim::News::Information)
      [Decidim::Permissions]
    else
      [
        reportable.participatory_space.manifest.permissions_class,
        Decidim::Permissions
      ]
    end
  end
end