# frozen_string_literal: true

Decidim::ResourceLocatorPresenter.class_eval do
  private

  # Private method checking if resource is one of the custom Models without defined manifest
  # through which url should be built.
  #
  # Returns: Boolean
  def simple_route?
    resource.is_a?(Decidim::ConsultationRequests::ConsultationRequest) ||
      resource.is_a?(Decidim::News::Information) ||
      resource.is_a?(Decidim::AdUsersSpace::ForumArticle)
  end

  # Overwritten private method
  #
  # The if statement was added new condition checking if target is one of the custom models instances,
  # for building URLs outside of the space or component namespace. Resource Locator is used in Notifications
  # and AdminLogs instances.
  #
  # Returns: String
  def member_route_name
    if simple_route?
      target.route_name
    elsif polymorphic?
      polymorphic_member_route_name
    else
      manifest_for(target).route_name
    end
  end
end